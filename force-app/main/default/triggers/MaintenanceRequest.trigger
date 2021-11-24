trigger MaintenanceRequest on Case (after update) {

    if(trigger.isAfter && trigger.isUpdate){

        Case[] followUpsToCreate = new Case[]{};
        for(Case maintRequest : Trigger.new){
            if(maintRequest.Status == 'Closed' && (maintRequest.Type == 'Repair' || maintRequest.Type == 'Routine Maintenance')){
                followUpsToCreate.add(maintRequest);
            }
        }

        MaintenanceRequestHelper.createFollowUpRequests(followUpsToCreate);
    }

}