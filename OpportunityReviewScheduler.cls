public class OpportunityReviewScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        createOpportunityReviewTasks();
    }  
    private void createOpportunityReviewTasks() {
        List<Opportunity> openOpportunities = [SELECT Id, OwnerId FROM Opportunity WHERE IsClosed = FALSE];
        List<Task> tasksToInsert = new List<Task>();
        for(Opportunity opp : openOpportunities) {
            Task newTask = new Task(
                WhatId = opp.Id,
                OwnerId = opp.OwnerId,
                Subject = 'Review Opportunity',
                Priority = 'Normal',
                Status = 'Not Started'
            );
            tasksToInsert.add(newTask);
        }      
        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }    
    public static void scheduleTask() {
        String cronExpression = '0 0 9 ? * MON'; 
        OpportunityReviewScheduler scheduler = new OpportunityReviewScheduler();
        System.schedule('Opportunity Review Scheduler', cronExpression, scheduler);
    }
}