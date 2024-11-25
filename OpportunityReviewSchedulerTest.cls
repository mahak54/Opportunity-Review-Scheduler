@isTest

public class OpportunityReviewSchedulerTest {
    @isTest
    static void testCreateOpportunityReviewTasks() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            OwnerId = testUser.Id
        );
        
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            OwnerId = testUser.Id
        );
        
        insert new List<Opportunity>{ opp1, opp2 };
        List<Opportunity> openOpportunities = [SELECT Id, OwnerId FROM Opportunity WHERE IsClosed = FALSE];
        System.assertEquals(2, openOpportunities.size(), 'There should be 2 open opportunities');
        Test.startTest();
        OpportunityReviewScheduler scheduler = new OpportunityReviewScheduler();
        scheduler.execute(null);
        Test.stopTest();
        List<Task> createdTasks = [SELECT WhatId, OwnerId, Subject FROM Task WHERE WhatId IN :openOpportunities];
        System.assertEquals(2, createdTasks.size(), 'There should be 2 tasks created');
        for (Task task : createdTasks) {
            System.assertEquals('Review Opportunity', task.Subject, 'The task subject should be "Review Opportunity"');
            System.assertEquals(testUser.Id, task.OwnerId, 'The task should be assigned to the Opportunity owner');
        }
    }
    @isTest
    static void testScheduleTask() {
        Test.startTest();
        OpportunityReviewScheduler.scheduleTask();
        Test.stopTest();
        CronTrigger[] cronTriggers = [SELECT Id, CronExpression FROM CronTrigger];
        System.assertEquals(1, cronTriggers.size(), 'There should be 1 scheduled job');
        System.assertEquals('0 0 9 ? * MON', cronTriggers[0].CronExpression, 'The cron expression should be set for Monday at 9:00 AM');
    }
}