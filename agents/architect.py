import json
from pathlib import Path

from services.openai_service import client


class ArchitectAgent:

    def design(self, requirement: str):

        prompt = Path("prompts/architect.txt").read_text()

        response = client.responses.create(
            model="gpt-5",
            instructions=prompt,
            input=requirement
        )

        try:
            return json.loads(response.output_text)
        except Exception:
            return {
                "error": response.output_text
            }