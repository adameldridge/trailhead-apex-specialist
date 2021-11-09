global class WarehouseSyncSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
     }
}
