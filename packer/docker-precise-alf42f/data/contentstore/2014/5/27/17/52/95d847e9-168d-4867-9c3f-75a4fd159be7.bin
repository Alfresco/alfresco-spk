function startWorkflow(assigneeGroup)
{
    var workflow = actions.create("start-workflow");
    workflow.parameters.workflowName = "activiti$activitiReviewPooled";
    workflow.parameters["bpm:workflowDescription"] = "Please review " + document.name;
    workflow.parameters["bpm:groupAssignee"] = assigneeGroup;
    var futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + 7);
    workflow.parameters["bpm:workflowDueDate"] = futureDate; 
    return workflow.execute(document);
}

function main()
{
   var name = document.name;
   var siteName = document.siteShortName;
   
   if (siteName == null)
   {
      if (logger.isLoggingEnabled())
         logger.log("Did not start workflow as the document named " + name + " is not located within a site.");
         
      return;
   }
   
   var reviewGroup = "GROUP_site_" + siteName;

   // make sure the group exists
   var group = people.getGroup(reviewGroup);
   if (group != null)
   {
      if (logger.isLoggingEnabled())
         logger.log("Starting pooled review and approve workflow for document named " + name + " assigned to group " + reviewGroup);

      startWorkflow(group);

      if (logger.isLoggingEnabled())
         logger.log("Started pooled review and approve workflow for document named " + name + " assigned to group " + reviewGroup);
   }
   else if (logger.isLoggingEnabled())
   {
      logger.log("Did not start workflow as the group " + reviewGroup + " could not be found.");
   }
}

main();
