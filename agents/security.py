import json
from pathlib import Path

from services.openai_service import client


class SecurityAgent:

    def review(self, requirement: str, architecture: dict):

        prompt = Path("prompts/security.txt").read_text()

        combined_input = f"""
Customer Requirement:
{requirement}

Architecture Recommendation:
{json.dumps(architecture, indent=2)}
"""

        response = client.responses.create(
            model="gpt-5",
            instructions=prompt,
            input=combined_input
        )

        try:
            return json.loads(response.output_text)
        except Exception:
            return {
                "error": response.output_text
            }