from workflow.workflow_manager import WorkflowManager

workflow = WorkflowManager()

result = workflow.execute(

    "Migrate 50 VMware VMs to Azure with Disaster Recovery and Cost Optimization."

)

print(result)