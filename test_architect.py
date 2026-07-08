from agents.architect import ArchitectAgent

architect = ArchitectAgent()

result = architect.design(
    "Migrate 50 VMware VMs to Azure with Disaster Recovery and Cost Optimization."
)

print(result)