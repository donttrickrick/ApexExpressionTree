/*
 * @changelog
 * This is a simplified class from financialforcedev unit of work (open soruce), find the original version at https://github.com/financialforcedev/fflib-apex-common/blob/master/fflib/src/classes/fflib_SObjectUnitOfWork.cls 
 * Learn more about unit of work on TrailHead https://trailhead.salesforce.com/en/modules/apex_patterns_sl/units/apex_patterns_sl_apply_uow_principles
 */
// Don't use with sharing because if called from other without sharing class (Test Class), SYSTEM_MODE_ENTER, SYSTEM_MODE_EXIT will go back and forth.
// Because of above reason, thinking to remove single sobject methods
public class SObjectUnitOfWork {
    private Map<String, List<sObject>> insertUnitMap = new Map<String, List<sObject>>();
    private Map<String, List<sObject>> updateUnitMap = new Map<String, List<sObject>>();
    private Map<String, List<sObject>> deleteUnitMap = new Map<String, List<sObject>>();
    private Map<String, ParentRecordRelationships> relationshipsMap = new Map<String, ParentRecordRelationships>();

    public final static SObjectUnitOfWork instance = new SObjectUnitOfWork();
    private SObjectUnitOfWork() {}
    
    private class ParentRecordRelationships {
        private List<Relationship> relationshipList= new List<Relationship>();

        public void resolve() {
            // Resolve relationships
            for(Relationship relationship : relationshipList) {
                relationship.record.put(relationship.parentFieldName, relationship.parent.Id);
            }
        }

        public void add(sObject r, String pf, sObject p) {
            relationshipList.add(new Relationship(r, pf, p));
        }
    }

    private class Relationship {
        public sObject record;
        public String parentFieldName;
        public sObject parent; 
        public Relationship(sObject r, String pf, sObject p) {
            record = r;
            parentFieldName = pf;
            parent = p;
        }
    }
    
    public SObjectUnitOfWork registerInsert(sObject sObj) {
        if(sObj == null) {
            return this;
        }
        String sObjectName = sObj.getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(insertUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = insertUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            insertUnitMap.put(sObjectName, sObjectUnitList);
        }
        sObjectUnitList.add(sObj);
        return this;
    }
    public SObjectUnitOfWork registerInsert(List<sObject> sObjList) {
        if(sObjList == null || sObjList.size() == 0) {
            return this;
        }
        String sObjectName = sObjList[0].getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(insertUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = insertUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            insertUnitMap.put(sObjectName, sObjectUnitList);
        }
        sObjectUnitList.addAll(sObjList);
        return this;
    }
    // Database.upsert or update DML doesn't support general sobject type, so have to break down into insert/update map
    public SObjectUnitOfWork registerUpsert(sObject sObj) {
        if(sObj == null) {
            return this;
        }
        String sObjectName = sObj.getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(sObj.Id == null) {
            if(insertUnitMap.containsKey(sObjectName)) {
                sObjectUnitList = insertUnitMap.get(sObjectName);
            } else {
                sObjectUnitList = new List<sObject>();
                insertUnitMap.put(sObjectName, sObjectUnitList);
            }
            sObjectUnitList.add(sObj);
        } else {
            if(updateUnitMap.containsKey(sObjectName)) {
                sObjectUnitList = updateUnitMap.get(sObjectName);
            } else {
                sObjectUnitList = new List<sObject>();
                updateUnitMap.put(sObjectName, sObjectUnitList);
            }
            if(!sObjectUnitList.contains(sObj)) {
            	sObjectUnitList.add(sObj);
        	}
        }
        return this;
    }
    // Database.upsert or update DML doesn't support general sobject type, so have to break down into insert/update map
    public SObjectUnitOfWork registerUpsert(List<sObject> sObjList) {
        if(sObjList == null || sObjList.size() == 0) {
            return this;
        }
        String sObjectName = sObjList[0].getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitInsertList = null;
        List<sObject> sObjectUnitUpdateList = null;
        
        for(sObject sObj : sObjList) {
            if(sObj.Id == null) {
                if(sObjectUnitInsertList == null) {
                    if(insertUnitMap.containsKey(sObjectName)) {
                        sObjectUnitInsertList = insertUnitMap.get(sObjectName);
                    } else {
                        sObjectUnitInsertList = new List<sObject>();
                        insertUnitMap.put(sObjectName, sObjectUnitInsertList);
                    }
                }
                sObjectUnitInsertList.add(sObj);
            } else {
                if(sObjectUnitUpdateList == null) {
                    if(updateUnitMap.containsKey(sObjectName)) {
                        sObjectUnitUpdateList = updateUnitMap.get(sObjectName);
                    } else {
                        sObjectUnitUpdateList = new List<sObject>();
                        updateUnitMap.put(sObjectName, sObjectUnitUpdateList);
                    }
                }
                if(!sObjectUnitUpdateList.contains(sObj)) {
                    sObjectUnitUpdateList.add(sObj);
                }
            }
        }
        return this;
    }
    public SObjectUnitOfWork registerUpdate(sObject sObj) {
        if(sObj == null) {
            return this;
        }
        String sObjectName = sObj.getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(updateUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = updateUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            updateUnitMap.put(sObjectName, sObjectUnitList);
        }
        if(!sObjectUnitList.contains(sObj)) {
            sObjectUnitList.add(sObj);
        }
        return this;
    }
    public SObjectUnitOfWork registerUpdate(List<sObject> sObjList) {
        if(sObjList == null || sObjList.size() == 0) {
            return this;
        }
        String sObjectName = sObjList[0].getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(updateUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = updateUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            updateUnitMap.put(sObjectName, sObjectUnitList);
        }
        for(sObject sObj : sObjList) {
            if(!sObjectUnitList.contains(sObj)) {
                sObjectUnitList.add(sObj);
            }
        }
        return this;
    }
    public SObjectUnitOfWork registerDelete(sObject sObj) {
        if(sObj == null) {
            return this;
        }
        String sObjectName = sObj.getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(deleteUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = deleteUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            deleteUnitMap.put(sObjectName, sObjectUnitList);
        }
        if(!sObjectUnitList.contains(sObj)) {
            sObjectUnitList.add(sObj);
        }
        return this;
    }
    public SObjectUnitOfWork registerDelete(List<sObject> sObjList) {
        if(sObjList == null || sObjList.size() == 0) {
            return this;
        }
        String sObjectName = sObjList[0].getSObjectType().getDescribe().getName();
        List<sObject> sObjectUnitList = null;
        if(deleteUnitMap.containsKey(sObjectName)) {
            sObjectUnitList = deleteUnitMap.get(sObjectName);
        } else {
            sObjectUnitList = new List<sObject>();
            deleteUnitMap.put(sObjectName, sObjectUnitList);
        }
        for(sObject sObj : sObjList) {
            if(!sObjectUnitList.contains(sObj)) {
                sObjectUnitList.add(sObj);
            }
        }
        return this;
    }
    public SObjectUnitOfWork bindRelationship(sObject binded, sObject parent, String parentFieldName) {
        if(binded == null || parent == null) {
            return this;
        }
        String sObjectName = parent.getSObjectType().getDescribe().getName();
        ParentRecordRelationships parentRelationships = null;
        if(relationshipsMap.containsKey(sObjectName)) {
            parentRelationships = relationshipsMap.get(sObjectName);
        } else {
            parentRelationships = new ParentRecordRelationships();
            relationshipsMap.put(sObjectName, parentRelationships);
        }
        parentRelationships.add(binded, parentFieldName, parent);
        return this;
    }
    public SObjectUnitOfWork bindRelationship(List<sObject> bindedList, sObject parent, String parentFieldName) {
        if(bindedList == null || bindedList.size() == 0 || parent == null) {
            return this;
        }
        String sObjectName = parent.getSObjectType().getDescribe().getName();
        ParentRecordRelationships parentRelationships = null;
        if(relationshipsMap.containsKey(sObjectName)) {
            parentRelationships = relationshipsMap.get(sObjectName);
        } else {
            parentRelationships = new ParentRecordRelationships();
            relationshipsMap.put(sObjectName, parentRelationships);
        }
        for(sObject binded : bindedList) {
            parentRelationships.add(binded, parentFieldName, parent);
        }
        return this;
    }
    public WorkResult commitWork() {
        // Wrap the work in its own transaction
        WorkResult result = new WorkResult();
        Savepoint sp = Database.setSavePoint();
        try {
            // Insert by type
            for(String key : insertUnitMap.keySet()) {
                System.debug('***Inserting ' + key + ' of ' + insertUnitMap.get(key).size() + ' records.');
                List<Database.SaveResult> insertResults = Database.insert(insertUnitMap.get(key));
                result.insertResultMap.put(key, insertResults);
                // Resolve binding
                if(relationshipsMap.containsKey(key)) { // order matters
                	relationshipsMap.get(key).resolve();
                }
            }
            
            // Update by type
            for(String key : updateUnitMap.keySet()) {
                System.debug('***Updating ' + key + ' of ' + updateUnitMap.get(key).size() + ' records.');
                List<Database.SaveResult> updateResults = Database.update(updateUnitMap.get(key));
                result.updateResultMap.put(key, updateResults);
            }
            
            // Delete by type (in reverse dependency order)
            for(Integer objectIdx = deleteUnitMap.keySet().size() - 1; objectIdx >= 0; objectIdx--) {
                System.debug('***Deleting ' + objectIdx + ' of ' + deleteUnitMap.values()[objectIdx].size() + ' records.');
                List<Database.DeleteResult> deleteResults = Database.delete(deleteUnitMap.values()[objectIdx]);
                result.deleteResultMap.put(new List<String>(deleteUnitMap.keySet())[objectIdx], deleteResults);
            }
            result.isSuccessful = true;
        }
        catch (Exception e) {
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        }
        finally {
        }
        return result;
    }
    
    public List<sObject> getInsertList(String objectName) {
        return insertUnitMap.containsKey(objectName) ? insertUnitMap.get(objectName) : new List<sObject>();
    }
    public List<sObject> getUpdateList(String objectName) {
        return updateUnitMap.containsKey(objectName) ? updateUnitMap.get(objectName) : new List<sObject>();
    }
    public List<sObject> getDeleteList(String objectName) {
        return deleteUnitMap.containsKey(objectName) ? deleteUnitMap.get(objectName) : new List<sObject>();
    }

    public class WorkResult {
        public Boolean isSuccessful = false;
        public Map<String, List<Database.SaveResult>> insertResultMap = new Map<String, List<Database.SaveResult>>();
        public Map<String, List<Database.SaveResult>> updateResultMap = new Map<String, List<Database.SaveResult>>();
        public Map<String, List<Database.DeleteResult>> deleteResultMap = new Map<String, List<Database.DeleteResult>>();
    }
}