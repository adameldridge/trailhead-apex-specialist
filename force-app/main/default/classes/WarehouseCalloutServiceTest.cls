@isTest
public with sharing class WarehouseCalloutServiceTest {

    @isTest
    static void insertNewEquipment(){
        // Set mock
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());        
        Test.startTest();
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        // Check all records are inserted
        Product2[] equipment = [SELECT Id
                                FROM Product2];
        
        System.assertEquals(22, equipment.size());
        
        // Check individual record details are correct
        Product2 equipmentItem = [SELECT Id, Replacement_Part__c, Cost__c, Lifespan_Months__c
                                  FROM Product2
                                  WHERE Name = 'Generator 1000 kW'
                                  LIMIT 1];

        System.assertEquals(true, equipmentItem.Replacement_Part__c);
        System.assertEquals(5000, equipmentItem.Cost__c);
        System.assertEquals(120, equipmentItem.Lifespan_Months__c);
    }

    @isTest
    static void testUpdateExistingEquipment(){
        //Insert record
        Product2 equipmentItem = new Product2();
        equipmentItem.Name = 'Ball Valve 10 cm';
        equipmentItem.Cost__c = 100;
        equipmentItem.Current_Inventory__c = 120;
        equipmentItem.Lifespan_Months__c = 4;
        equipmentItem.Maintenance_Cycle__c = 5;
        equipmentItem.Warehouse_SKU__c = '100009';
        insert equipmentItem;

        // Call mocked endpoint
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());        
        Test.startTest();
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        // Check record has been updated
        Product2 updatedEquipmentItem = [SELECT Id, Name, Replacement_Part__c, Cost__c, Lifespan_Months__c, Current_Inventory__c, Maintenance_Cycle__c
                                         FROM Product2
                                         WHERE Warehouse_SKU__c = '100009'
                                         LIMIT 1];
        
        System.assertEquals(true, updatedEquipmentItem.Replacement_Part__c);
        System.assertEquals('Ball Valve 10 cm', updatedEquipmentItem.Name);
        System.assertEquals(50, updatedEquipmentItem.Cost__c);
        System.assertEquals(90, updatedEquipmentItem.Current_Inventory__c);
        System.assertEquals(0, updatedEquipmentItem.Lifespan_Months__c);
        System.assertEquals(0, updatedEquipmentItem.Maintenance_Cycle__c);

    }
}
