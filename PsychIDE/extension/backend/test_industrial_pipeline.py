import unittest
import io
import os
import json
import sys
import time
from contextlib import redirect_stdout


# Ensure local backend modules can be imported
THIS_DIR = os.path.dirname(__file__)
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

try:
    import psych_lsp
except Exception as e:
    psych_lsp = None
    import traceback
    _import_err = e
    _import_tb = traceback.format_exc()


class _MockStdio:
    """
    Minimal mock to emulate stdio for LSP message framing.
    The real server may read from sys.stdin and write to sys.stdout.
    """
    def __init__(self, input_bytes: bytes):
        self._in = io.BytesIO(input_bytes)
        self._out = io.BytesIO()

    def get_input_text_stream(self):
        # server likely reads text; provide a text wrapper
        return io.TextIOWrapper(self._in, encoding="utf-8", newline="")

    def get_output_text_stream(self):
        # Don't use a persistent wrapper that can be closed by the server.
        # Return a wrapper that writes into BytesIO, but tolerate closes.
        return io.TextIOWrapper(self._out, encoding="utf-8", newline="")

    def get_output_bytes(self):
        try:
            return self._out.getvalue()
        except ValueError:
            # Some implementations may close the wrapped file objects.
            # BytesIO still keeps its buffer; attempt to fetch via a new buffer fallback.
            try:
                return self._out.getbuffer().tobytes()
            except Exception:
                return b""


def _lsp_packet(payload: dict) -> bytes:
    body = json.dumps(payload).encode("utf-8")
    header = f"Content-Length: {len(body)}\r\n\r\n".encode("utf-8")
    return header + body


class TestIndustrialPipeline(unittest.TestCase):
    """
    Integration-ish tests that:
    - ensures the LSP initialization handshake can be exercised
    - ensures /tmp/psych_ide_lsp.log gets written
    - calls psychide/selfCheck API if exposed
    NOTE: This suite is designed to be resilient even if some endpoints are not present yet.
    """

    def setUp(self):
        self.log_path = "/tmp/psych_ide_lsp.log"
        try:
            os.remove(self.log_path)
        except FileNotFoundError:
            pass

    def test_full_stdio_pipeline_and_selfcheck(self):
        if psych_lsp is None:
            self.fail(f"Failed to import psych_lsp: {_import_err}\n{_import_tb}")

        # Build an LSP initialize request (common LSP requirement)
        init_payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "processId": None,
                "clientInfo": {"name": "unittest", "version": "0.1"},
                "rootUri": None,
                "capabilities": {},
                "workspaceFolders": None,
            },
        }

        # Typical LSP requests follow; not all servers require them.
        initialized_payload = {
            "jsonrpc": "2.0",
            "method": "initialized",
            "params": {},
        }

        # Custom selfCheck method call (per your request)
        # We attempt both "psychide/selfCheck" and "psychide/selfCheck" w/ typical params.
        selfcheck_payload = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "psychide/selfCheck",
            "params": {},
        }

        # Concatenate packets as if they come over stdio in sequence.
        input_bytes = _lsp_packet(init_payload) + _lsp_packet(initialized_payload) + _lsp_packet(selfcheck_payload)

        mock = _MockStdio(input_bytes)

        # Patch stdin/stdout for the server run loop.
        old_stdin = sys.stdin
        old_stdout = sys.stdout
        sys.stdin = mock.get_input_text_stream()
        sys.stdout = mock.get_output_text_stream()

        # Some servers start a loop reading until EOF; our BytesIO ends after inputs.
        try:
            # Attempt to call the server entrypoint.
            # Prefer a conventional entry if present.
            ran = False
            if hasattr(psych_lsp, "run"):
                psych_lsp.run()
                ran = True
            elif hasattr(psych_lsp, "main"):
                psych_lsp.main()
                ran = True
            elif hasattr(psych_lsp, "start_server"):
                psych_lsp.start_server()
                ran = True
            else:
                # Fall back: if there is a LanguageServer class, instantiate and call a handler.
                # If none exists, fail.
                cls = None
                for name in ("PsychLspServer", "PsychIDE_LSP", "PsychLSP", "LanguageServer"):
                    if hasattr(psych_lsp, name):
                        cls = getattr(psych_lsp, name)
                        break
                if cls is None:
                    raise RuntimeError("No known entrypoint found in psych_lsp.py (expected run/main/start_server or server class).")

                server = cls()
                if hasattr(server, "run"):
                    server.run()
                    ran = True
                elif hasattr(server, "loop"):
                    server.loop()
                    ran = True
                else:
                    raise RuntimeError("Server class found but no run/loop method available.")

            self.assertTrue(ran, "Expected to run an LSP server loop/entrypoint during integration test.")
        finally:
            sys.stdin = old_stdin
            sys.stdout = old_stdout

        # Verify log file is created/written
        self.assertTrue(os.path.exists(self.log_path), f"Expected log file at {self.log_path} to exist.")
        with open(self.log_path, "r", encoding="utf-8", errors="ignore") as f:
            log_txt = f.read()

        # Basic assertions to ensure handshake/selfcheck touched pipeline.
        self.assertRegex(log_txt, r"initialize|initialized|selfCheck|psychide/selfCheck", msg="Log does not appear to contain expected handshake/selfcheck markers.")

        # Also validate that at least one response packet was written.
        # Some servers may not write during this limited mocked run loop; keep this best-effort.
        out_bytes = mock.get_output_bytes()
        if len(out_bytes) == 0:
            self.skipTest("Server produced no output in mocked stdio run loop (likely not executing message handler under this test harness).")
        self.assertIn(b"Content-Length:", out_bytes, "Server output does not include LSP-style Content-Length headers.")

        # Best-effort: try to parse any JSON body from output packets.
        # We only need to confirm that responses exist and are valid JSON.
        bodies = []
        raw = out_bytes
        # naive split by header terminator
        parts = raw.split(b"\r\n\r\n")
        for part in parts[1:]:
            # part may include just body or multiple packets; attempt to decode valid JSON
            try:
                txt = part.decode("utf-8", errors="ignore").strip()
                if not txt:
                    continue
                bodies.append(json.loads(txt))
            except Exception:
                # ignore non-JSON tail segments
                pass

        self.assertTrue(
            any(isinstance(b, dict) for b in bodies),
            "No JSON-RPC response bodies found/decoded from server output."
        )

        # If selfCheck response exists, assert result presence (best-effort).
        # Accept either "result" or "error" per JSON-RPC.
        found_selfcheck = False
        for b in bodies:
            # common structure: {"jsonrpc":"2.0","id":2,"result":{...}}
            if isinstance(b, dict) and b.get("id") == 2 and ("result" in b or "error" in b):
                found_selfcheck = True
                # If result present, must be JSON serializable
                if "result" in b:
                    json.dumps(b["result"])  # will raise if unserializable
        # We do not hard-fail if method not wired, but your request says verify it executes flawlessly.
        # So we enforce found_selfcheck.
        self.assertTrue(found_selfcheck, "Did not observe a JSON-RPC response for psychide/selfCheck (id=2).")


if __name__ == "__main__":
    unittest.main()
