import unittest

from ai_client import PsychAIClient
from psych_lsp import PsychLanguageServer


class AIConfigurationTests(unittest.TestCase):
    def test_client_configures_and_clears_key_in_memory(self):
        client = PsychAIClient()
        client.set_api_key("runtime-test-key")
        self.assertEqual(client.api_key, "runtime-test-key")
        self.assertIn("runtime-test-key", client.api_url)
        client.clear_api_key()
        self.assertEqual(client.api_key, "")
        self.assertEqual(client.api_url, "")

    def test_lsp_configuration_does_not_return_key(self):
        server = PsychLanguageServer()
        response = server.configure_ai_key({"apiKey": "runtime-test-key"})
        self.assertEqual(response, {"ok": True, "configured": True})
        self.assertNotIn("runtime-test-key", response)
        cleared = server.configure_ai_key({"apiKey": ""})
        self.assertEqual(cleared, {"ok": True, "configured": False})


if __name__ == "__main__":
    unittest.main()
