@isTest
public with sharing class MaintenanceRequestHelperTest {

    @isTest
    static void createRepairFollowUp(){

        //Create Vehicle
        Vehicle__c vehicle = new Vehicle__c();
        vehicle.Make__c = 'Ford';
        vehicle.Model__c = 'Fiesta';
        insert vehicle;

        //Create Case Details
        Case maintRequest = new Case();
        maintRequest.Type = 'Repair';
        maintRequest.Subject = 'Test';
        maintRequest.Status = 'New';
        maintRequest.Vehicle__c = vehicle.Id;
        insert maintRequest;

        //Create Product
        Product2 equipment = new Product2();
        equipment.Maintenance_Cycle__c = 2;
        equipment.Name = 'Test Equipment';
        equipment.Replacement_Part__c = true;
        insert equipment;

        //Create Equipment Maintenance Item
        Equipment_Maintenance_Item__c equipMainItem = new Equipment_Maintenance_Item__c();
        equipMainItem.Equipment__c = equipment.Id;
        equipMainItem.Maintenance_Request__c = maintRequest.Id;
        insert equipMainItem;

        // Update to launch trigger
        maintRequest.Status = 'Closed';
        update maintRequest;


        // Verify case is created
        Case newMaintRequest = [SELECT Id, Type, Subject, Date_Reported__c, Date_Due__c, Vehicle__c
                                FROM Case
                                WHERE Subject = 'Follow up routine maintenance'
                                AND Status = 'New'
                                LIMIT 1];

        System.assertEquals('Routine Maintenance',newMaintRequest.Type);
        System.assertEquals(maintRequest.Vehicle__c, newMaintRequest.Vehicle__c);

        // Verify Equipment_Maintenance_Item__c record is created
        Equipment_Maintenance_Item__c newEquipMainItem = [SELECT Id, Equipment__c
                                                          FROM Equipment_Maintenance_Item__c
                                                          WHERE Maintenance_Request__c =: newMaintRequest.Id
                                                          LIMIT 1];
        
        System.assertEquals(newEquipMainItem.Equipment__c, equipment.Id);

    }

}