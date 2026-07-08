from agents.planner import PlannerAgent
from agents.architect import ArchitectAgent


class WorkflowManager:

    def __init__(self):

        self.planner = PlannerAgent()
        self.architect = ArchitectAgent()

    def execute(self, requirement: str):

        results = {}

        # Step 1
        plan = self.planner.analyze(requirement)

        results["planner"] = plan

        # Step 2
        if "Cloud Architect" in plan["selected_agents"]:

            architecture = self.architect.design(requirement)

            results["architecture"] = architecture

        return results