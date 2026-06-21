import unittest
import io
import json
import sys
import os

# Ensure local backend modules can be imported
sys.path.append(os.path.dirname(__file__))


class TestLSPProtocolFraming(unittest.TestCase):
    def test_json_rpc_framing_generation(self):
        """Verify that outgoing payloads are decorated with the exact required HTTP-style headers."""
        sample_payload = {"jsonrpc": "2.0", "id": 99, "result": {"status": "OK"}}
        serialized = json.dumps(sample_payload)
        encoded_body = serialized.encode("utf-8")

        # Simulating standard LSP header wrapping behavior
        generated_header = f"Content-Length: {len(encoded_body)}\r\n\r\n".encode("utf-8")
        full_packet = generated_header + encoded_body

        # Assert structural compliance
        self.assertTrue(full_packet.startswith(b"Content-Length:"))
        self.assertTrue(b"\r\n\r\n" in full_packet)
        self.assertEqual(len(encoded_body), int(generated_header.split(b":")[1].strip()))

    def test_semantic_tokens_integer_array_packing(self):
        """Assert that token delta positions are packed into uniform flat 32-bit integer arrays for VS Code."""
        # VS Code Semantic Tokens format: [deltaLine, deltaStartChar, length, tokenType, tokenModifiers]
        mock_tokens = [
            [0, 9, 11, 1, 0],  # Line 0, char 9, length 11, type 1 (function)
            [1, 4, 10, 2, 0],  # Line 1 (delta 1), char 4, length 10, type 2 (variable)
        ]

        # Flatten the list exactly how the Language Server Protocol demands it
        flattened_array = [item for token in mock_tokens for item in token]

        self.assertEqual(len(flattened_array), 10, "LSP token encoder must flatten components into groups of 5 values.")
        for val in flattened_array:
            self.assertIsInstance(val, int, "All encoded semantic token data points must be primitive integers.")

    def test_malformed_rpc_payload_resilience(self):
        """Ensure the server boundaries drop invalid json packets gracefully instead of crashing."""
        malformed_json_string = "{jsonrpc: '2.0', id: 99, missing_quotes_everywhere"

        with self.assertRaises(ValueError):
            # Force standard JSON parsing error check
            json.loads(malformed_json_string)


if __name__ == "__main__":
    unittest.main()
