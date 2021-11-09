public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts{

    public static void execute(QueueableContext context){

        // Set up HTTP request and headers
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        httpResponse = http.send(httpRequest);

        Equipment[] warehouseEquipment = new Equipment[]{};
        warehouseEquipment = (Equipment[]) JSON.deserialize(httpResponse.getBody().replaceAll('_id', 'id'), Equipment[].class);

        // Create map of SKU to warehouse equipment item
        Map<String,Equipment> skuToWarehouseEquipment = new Map<String,Equipment>();
        for(Equipment wareHouseEquipmentItem:warehouseEquipment){
            skuToWarehouseEquipment.put(wareHouseEquipmentItem.sku, wareHouseEquipmentItem);
        }

        // Get Equipment to update
        Product2[] sfEquipment = [SELECT Id, Name, Warehouse_SKU__c
                                        FROM Product2
                                        WHERE Warehouse_SKU__c IN: skuToWarehouseEquipment.keySet()];
        
        // Create map of SKU to SF item
        Map<String,Product2> skuToSfEquipment = new Map<String,Product2>();
        for(Product2 sfEquipmentItem:sfEquipment){
            skuToSfEquipment.put(sfEquipmentItem.Warehouse_SKU__c,sfEquipmentItem);
        }

        // Ceate or update data
        Product2[] equipmentToUpsert = new Product2[]{};
        for(Equipment wareHouseEquipmentItem:skuToWarehouseEquipment.values()){
            Product2 equipmentItem = new Product2();

            // Populate Id if SKU can be found in salesforce
            if(skuToSfEquipment.containsKey(wareHouseEquipmentItem.sku)){
                equipmentItem.Id = skuToSfEquipment.get(wareHouseEquipmentItem.sku).Id;
                equipmentItem.Name = skuToSfEquipment.get(wareHouseEquipmentItem.sku).Name;
            }

            // Map values from response
            equipmentItem.Name = wareHouseEquipmentItem.name;
            equipmentItem.Replacement_Part__c = true;
            equipmentItem.Cost__c = wareHouseEquipmentItem.cost;
            equipmentItem.Current_Inventory__c = wareHouseEquipmentItem.quantity;
            equipmentItem.Lifespan_Months__c = wareHouseEquipmentItem.lifespan;
            equipmentItem.Maintenance_Cycle__c = wareHouseEquipmentItem.maintenanceperiod;
            equipmentToUpsert.add(equipmentItem);

        }
        upsert equipmentToUpsert;
     
    }

    class Equipment{
        public String id;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenanceperiod;
        public Integer lifespan;
        public Integer cost;
        public String sku;
    }





}
