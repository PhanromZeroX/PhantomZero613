import unittest

import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from psych_lsp import PsychLanguageServer




class TestPsychLanguageServerInit(unittest.TestCase):
    def test_initialize_with_null_rootUri_and_semantic_tokens(self):
        server = PsychLanguageServer()
        response = server.initialize({"rootUri": None})

        # Ensure initialize returns capabilities and semanticTokensProvider is advertised
        self.assertIn("capabilities", response)
        caps = response["capabilities"]
        self.assertIn("semanticTokensProvider", caps)
        self.assertIsInstance(caps["semanticTokensProvider"], dict)


if __name__ == "__main__":
    unittest.main()

