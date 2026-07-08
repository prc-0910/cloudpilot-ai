import json
from pathlib import Path

from services.openai_service import client


class PlannerAgent:

    def analyze(self, requirement: str):

        prompt = Path("prompts/planner.txt").read_text()

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