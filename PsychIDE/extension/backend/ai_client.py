"""
PsychIDE AI Debugger Client.
Communicates with the Gemini API to explain and fix Psych Engine Lua errors.
"""

import os
import json
import urllib.request
import logging

class PsychAIClient:
    def __init__(self):
        # To use this, you'll need to set your GEMINI_API_KEY environment variable,
        # or hardcode your key right here (though environment variables are safer!).
        self.api_key = os.environ.get("GEMINI_API_KEY", "")
        self.api_url = ""
        self.set_api_key(self.api_key)

    def set_api_key(self, api_key: str) -> None:
        """Set the runtime-only key without persisting or logging it."""
        self.api_key = api_key.strip()
        self.api_url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"gemini-2.5-flash:generateContent?key={self.api_key}"
            if self.api_key else ""
        )

    def clear_api_key(self) -> None:
        self.set_api_key("")

    def ask_ai_to_fix(self, error_msg: str, line_code: str) -> dict:
        """
        Sends the broken code and the error message to the AI and asks for a fix.
        """
        if not self.api_key:
            return {"error": "AI debugger is offline. Set GEMINI_API_KEY to enable it."}
        
        # 🧠 The System Prompt: Telling the AI exactly how to act
        prompt = (
            "You are an elite, expert Psych Engine (Friday Night Funkin') modder. "
            "Your job is to help a user fix a bug in their Lua script.\n\n"
            f"❌ The user's code triggered this error/warning: '{error_msg}'\n"
            f"📜 The problematic line of code is:\n`{line_code}`\n\n"
            "Return only valid JSON with exactly two string fields: "
            '{"explanation":"brief explanation","fixed_code":"corrected line"}. '
            "Do not use markdown or add extra fields."
        )
        
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": 0.2 # Low temperature keeps the code fixes highly accurate and focused
            }
        }
        
        try:
            # Send the request to the AI API
            req = urllib.request.Request(
                self.api_url, 
                data=json.dumps(payload).encode('utf-8'),
                headers={'Content-Type': 'application/json'},
                method='POST'
            )
            
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                text = result['candidates'][0]['content']['parts'][0]['text'].strip()
                parsed = json.loads(text)
                if not isinstance(parsed, dict) or not isinstance(parsed.get("fixed_code"), str):
                    return {"error": "AI returned an invalid patch response."}
                return {
                    "explanation": str(parsed.get("explanation", "")),
                    "fixed_code": parsed["fixed_code"],
                }
                
        except Exception as e:
            logging.error(f"AI Connection Error: {str(e)}")
            return {"error": f"Could not reach the AI server. ({str(e)})"}