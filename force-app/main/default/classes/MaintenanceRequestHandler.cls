public with sharing class MaintenanceRequestHandler {

    public static void createFollowUpRequests(Case[] oldMaintRequests){

        Map<Id,Case> idToCase = new Map<Id,Case>();
        idToCase.putAll(oldMaintRequests);

        oldMaintRequests = [SELECT Id,Vehicle__c,(SELECT Id, Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c, Equipment__c FROM Equipment_Maintenance_Items__r) 
                            FROM Case
                            WHERE Id IN: idToCase.keySet()];
        
        Case[] newMaintRequests = new Case[]{};
        Map<Integer, Case> indexToCase = new Map<Integer, Case>();
        Map<Integer, Equipment_Maintenance_Item__c[]> indexToEquipment = new Map<Integer, Equipment_Maintenance_Item__c[]>();

        Integer i = 0;
        for(Case oldMaintRequest:oldMaintRequests){

            Case newMaintRequest = new Case();
            newMaintRequest.Vehicle__c = oldMaintRequest.Vehicle__c;
            newMaintRequest.Type = 'Routine Maintenance';
            newMaintRequest.Subject = 'Follow up routine maintenance';
            newMaintRequest.Date_Reported__c = Date.today();
            
            if(!oldMaintRequest.Equipment_Maintenance_Items__r.isEmpty()){
                //Adding entry of index to list of products to map
                indexToEquipment.put(i, oldMaintRequest.Equipment_Maintenance_Items__r);

                // Get lowest number of days until maint required
                Integer[] mainCycleDaysList =  new Integer[]{};
                for(Equipment_Maintenance_Item__c oldMaintItem:oldMaintRequest.Equipment_Maintenance_Items__r){
                    mainCycleDaysList.add(oldMaintItem.Equipment__r.Maintenance_Cycle__c.intValue());
                }
                mainCycleDaysList.sort();
                newMaintRequest.Date_Due__c = Date.today().addDays(mainCycleDaysList[0]);
            }

            indexToCase.put(i,newMaintRequest);
            i++;
        }

        insert indexToCase.values();
        
        
        // loop through new requests and create Equipment_Maintenance_Item__c (junction object)
        Equipment_Maintenance_Item__c[] equipMaintItemsToInsert = new Equipment_Maintenance_Item__c[]{};

        for(Integer index:indexToCase.keySet()){
            Case newMaintRequest = indexToCase.get(index);
            System.debug(newMaintRequest.Id);
            
            Equipment_Maintenance_Item__c[] equipmentList = new Equipment_Maintenance_Item__c[]{};
            if(indexToEquipment.containsKey(index)){
                equipmentList = indexToEquipment.get(index);
            }

            // Loop through equipment for each case and create new junction object to insert
            for(Equipment_Maintenance_Item__c oldEquipMainItem:equipmentList){
                Equipment_Maintenance_Item__c equipMainItem = new Equipment_Maintenance_Item__c();
                equipMainItem.Equipment__c = oldEquipMainItem.Equipment__c;
                equipMainItem.Maintenance_Request__c = newMaintRequest.Id;
                equipMaintItemsToInsert.add(equipMainItem);
            }

        }
        insert equipMaintItemsToInsert;
    }
}
