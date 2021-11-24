@isTest
public with sharing class WarehouseSyncScheduleTest {
 
    @isTest
    static void testSchedule(){

        WarehouseSyncSchedule sync = new WarehouseSyncSchedule();
        String sch = '20 30 8 10 2 ?';
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());  
        String jobID = system.schedule('WarehouseSyncScheduleJobTest', sch, sync);

        CronTrigger ct = [SELECT Id, TimesTriggered, CronExpression
                          FROM CronTrigger 
                          WHERE Id = :jobID];

        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(sch, ct.CronExpression);
        System.assertNotEquals(null, ct.Id);
        

    }
}
