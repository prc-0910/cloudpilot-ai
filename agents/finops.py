import json
from pathlib import Path

from services.openai_service import client


class FinOpsAgent:

    def analyze(self, requirement: str, architecture: dict):

        prompt = Path("prompts/finops.txt").read_text()

        response = client.responses.create(
            model="gpt-5",
            instructions=prompt,
            input=f"""
Customer Requirement:

{requirement}

Architecture:

{json.dumps(architecture, indent=2)}
"""
        )

        return json.loads(response.output_text)