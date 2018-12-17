/**
 * Copyright 2017 donttrickrick@github.com
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// 1. Dynamic. Assuming you know what you are doing, which means below:
// 2. SObject: If you don't have access to field, a system error will occur.
// 3. SObject: If you type wrong field name or wrong field path, a system error will occur.
// 4. Object value: You know string type value never equals integer value, but you can compare these, no error occur and you will get empty result.
// 4.1. null integer eq null string.
// 4.2. 1 integer eq 1 double because.
// 5. Functions: Any Place has compararion is comparing hash. 
// 5.1. you can pass parent field to where to compare with another object. 
// 5.2. selectSObject and selectSObjects cannot be used to select value. If you do, a system error will occur.
// 5.3. selectId, selectAny, selectString cannot be used to select sobject or object. If you do, a system error will occur.
// 6. Field is NOT case sensitive.
public class SObjectList {
    private final List<SObject> l;
    
    public SObjectList(List<SObject> sObjList) {
        l = sObjList == null ? new List<SObject>() : sObjList;
    }
    public SObjectList(SObject sObj) {
    	l = new List<SObject> { sObj };
    }
    public SObjectList() {
    	l = new List<SObject>();
    }
    public Integer size() {
        return l.size();
    }
    public SObject first() {
        return size() > 0 ? l[0] : null;
    }
    public SObject first(String field, Object predictedValue) {
        SObject firstObj = null;
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                firstObj = sObj;
                break;
            }
        }
        return firstObj;
    }
    public SObject last() {
        return size() > 0 ? l[size() - 1] : null;
    }
    public SObject last(String field, Object predictedValue) {
        SObject lastObj = null;
        String[] fieldPath = field.trim().split('[.]');
        for(Integer i = l.size() - 1; i > -1; i--) {
            SObject sObj = l[i];
            if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                lastObj = sObj;
                break;
            }
        }
        return lastObj;
    }
    public List<SObject> toList() {
        return l;
    }
    public Map<Object, SObject> toMap(String identityField) {
        Map<Object, SObject> sObjMap = new Map<Object, SObject>();
        String[] identityFieldPath = identityField.trim().split('[.]');
        for(SObject sObj : l) {
            Object key = getFieldValue(sObj, identityFieldPath, true);
            sObjMap.put(key, sObj);
        }
        return sObjMap;
    }
    public List<Map<String, Object>> toObjectList() {
        List<Map<String, Object>> lst = new List<Map<String, Object>>();
        for(SObject sObj : l) {
            Map<String, Object> sObjMap = new Map<String, Object>(sObj.getPopulatedFieldsAsMap());
            if(!sObjMap.containsKey('sobjectType')) {
                sObjMap.put('sobjectType', sObj.getSObjectType());
            }
            lst.add(sObjMap);
        }
        return lst;
    }
    /*
    public List<Map<String, Object>> toUIMap(String fields, String mockupFieldName) {
        // List<Map<String, Map<String, Object>>> mList = new List<Map<String, Map<String, Object>>>();
        List<Map<String, Object>> mList = new List<Map<String, Object>>();
        mockupFieldName = String.isEmpty(mockupFieldName) ? 'field' : mockupFieldName;
        String[] fieldArray = fields.split('\\s*[,]\\s*');
        system.debug('fieldArray:'+fieldArray);
        
        for(SObject sObj : this.l) {
            // Map<String, Map<String, Object>> sMap = new Map<String, Map<String, Object>>();
            Map<String, Object> sMap = sObj.getPopulatedFieldsAsMap().clone();
            Integer i = 0;
            for(String fieldStr : fieldArray) {
                Object value = getFieldValue(sObj, fieldStr, true);
                
                sMap.put(mockupFieldName + i++, new Map<String, Object> {
                    'APIName' => fieldStr,
                    'Type' => String.valueOf(Primitives.valueOf(getFieldValue(sObj, fieldStr, true)).type),
                    'Value' => getFieldValue(sObj, fieldStr, true)
                });
            }
            mList.add(sMap);
        }
        return mList;
    }
    */
    public void add(SObject sObj) {
    	l.add(sObj);
    }
    public void addAll(List<SObject> sObjList) {
    	l.addAll(sObjList);
    }
    public void addAll(SObjectList sObjList) {
    	l.addAll(sObjList.l);
    }
    public SObjectList whereNotEq(String field, Object predictedValue) {
    	return whereNotEq(field, predictedValue, null);
    }
    public SObjectList whereNotEq(String field, Object predictedValue, Integer limitation) {
        SObjectList whereList = new SObjectList();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
        	if(limitation != null && whereList.size() >= limitation) {
				break;            	
            }
            if(getFieldValue(sObj, fieldPath, true) != predictedValue) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }
    public SObjectList whereNotIn(String field, List<Object> predictedValueList) {
    	return whereNotIn(field, predictedValueList, null);
    }
    public SObjectList whereNotIn(String field, List<Object> predictedValueList, Integer limitation) {
        SObjectList whereList = new SObjectList();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
        	if(limitation != null && whereList.size() >= limitation) {
				break;            	
            }
            Boolean isIn = false;
            for(Object predictedValue : predictedValueList) {
                if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                    isIn = true;
                    break;
                }
            }
            if(!isIn) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }
    public SObjectList whereEq(String field, Object predictedValue) {
    	return whereEq(field, predictedValue, null);
    }
    public SObjectList whereEq(String field, Object predictedValue, Integer limitation) {
        SObjectList whereList = new SObjectList();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
        	if(limitation != null && whereList.size() >= limitation) {
				break;            	
            }
            if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }
    public SObjectList whereIn(String field, List<Object> predictedValueList) {
    	return whereIn(field, predictedValueList, null);
    }
    public SObjectList whereIn(String field, List<Object> predictedValueList, Integer limitation) {
        SObjectList whereList = new SObjectList();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
        	if(limitation != null && whereList.size() >= limitation) {
				break;            	
            }
            Boolean isIn = false;
            for(Object predictedValue : predictedValueList) {
                if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                    isIn = true;
                    break;
                }
            }
            if(isIn) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }
    public Map<Object, SObjectList> groupBy(String field) {
        Map<Object, SObjectList> sObjMap = new Map<Object, SObjectList>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            SObjectList sObjList = null;
            Object key = getFieldValue(sObj, fieldPath, true);
            if(sObjMap.containsKey(key)) {
                sObjList = sObjMap.get(key);
            } else {
                sObjList = new SObjectList();
                sObjMap.put(key, sObjList);
            }
            sObjList.add(sObj);
        }
        return sObjMap;
    }
    public Map<String, SObjectList> groupByString(String field) {
        Map<String, SObjectList> sObjMap = new Map<String, SObjectList>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            SObjectList sObjList = null;
            String key = String.valueOf(getFieldValue(sObj, fieldPath, true));
            if(sObjMap.containsKey(key)) {
                sObjList = sObjMap.get(key);
            } else {
                sObjList = new SObjectList();
                sObjMap.put(key, sObjList);
            }
            sObjList.add(sObj);
        }
        return sObjMap;
    }
    public SObjectList groupByThenGet(String groupByField, Object key) {
        SObjectList sObjList = new SObjectList();
        Map<Object, SObjectList> sObjMap = groupBy(groupByField);
        if(sObjMap.containsKey(key)) {
            sObjList = sObjMap.get(key);
        }
        return sObjList;
    }
    // public Map<String, List<SObject>> groupByReturnSObject(String field) {
    //     Map<String, List<SObject>> sObjMap = new Map<String, List<SObject>>();
    //     for(SObject sObj : l) {
    //         List<SObject> sObjList = null;
    //         String key = String.valueOf(getFieldValue(sObj, field, true));
    //         if(sObjMap.containsKey(key)) {
    //             sObjList = sObjMap.get(key);
    //         } else {
    //             sObjList = new List<SObject>();
    //             sObjMap.put(key, sObjList);
    //         }
    //         sObjList.add(sObj);
    //     }
    //     return sObjMap;
    // }
    public SObjectList orderBy(String field) {
        List<Object> valueList = new List<Object>();
        Map<Object, List<SObject>> valueMap = new Map<Object, List<SObject>>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
           Object val = getFieldValue(sObj, fieldPath, true);
           List<SObject> subSObjList = null;
           if(valueMap.containsKey(val)) {
               subSObjList = valueMap.get(val);
           } else {
               subSObjList = new List<SObject>();
               valueList.add(val);
               valueMap.put(val, subSObjList);
           }
           subSObjList.add(sObj);
       }
       valueList.sort();
       SObjectList sObjList = new SObjectList();
       for(Object val : valueList) {
           sObjList.addAll(valueMap.get(val));
       }
       return sObjList;
    }
    public SObjectList orderByDESC(String field) {
        return orderBy(field).reverse();
    }
    public List<Object> selectAny(String field) {
        List<Object> objList = new List<Object>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            objList.add(getFieldValue(sObj, fieldPath, true));
        }
        return objList;
    }
    public List<String> selectString(String field) {
        List<String> objList = new List<String>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            objList.add((String)getFieldValue(sObj, fieldPath, true));
        }
        return objList;
    }
    public List<Id> selectId(String field) {
        List<Id> idList = new List<Id>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            idList.add((Id)getFieldValue(sObj, fieldPath, true));
        }
        return idList;
    }
    public SObjectList selectSObject(String field) {
        List<SObject> sObjList = new List<SObject>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            sObjList.add((SObject)getFieldValue(sObj, fieldPath, false));
        }
        return new SObjectList(sObjList);
    }
    public SObjectList selectSObjects(String field) {
        List<SObject> sObjList = new List<SObject>();
        for(SObject sObj : l) {
            sObjList.addAll(sObj.getSObjects(field));
        }
        return new SObjectList(sObjList);
    }
    public SObjectList distinct(String field) {
        List<SObject> cloned = l.clone(); // shallow clone
        String[] fieldPath = field.trim().split('[.]');
        for(Integer i = 0; i < cloned.size(); i++) {
            for(Integer j = i + 1; j < cloned.size(); j++) {
                if(getFieldValue(cloned[i], fieldPath, true) == getFieldValue(cloned[j], fieldPath, true)) {
                    cloned.remove(j);
                    j--;
                }
            }
        }
        return new SObjectList(cloned);
    }
    public Boolean one(String field, List<Object> predictedValueList) {
        Boolean ret = false;
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            for(Object predictedValue : predictedValueList) {
                ret = getFieldValue(sObj, fieldPath, true) == predictedValue;
                if(ret) {
	                break;
	            }
            }
            if(ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean all(String field, List<Object> predictedValueList) {
        Boolean ret = null;
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            for(Object predictedValue : predictedValueList) {
                ret = ret == null ? getFieldValue(sObj, fieldPath, true) == predictedValue : ret & getFieldValue(sObj, fieldPath, true) == predictedValue;
            }
            if(!ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean one(String field, Object predictedValue) {
        Boolean ret = false;
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            if(getFieldValue(sObj, fieldPath, true) == predictedValue) {
                ret = true;
                break;
            }
        }
        return ret;
    }
    public Boolean all(String field, Object predictedValue) {
        Boolean ret = null;
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            ret = ret == null ? getFieldValue(sObj, fieldPath, true) == predictedValue : ret & getFieldValue(sObj, fieldPath, true) == predictedValue;
            if(!ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean isEmpty() {
        return size() == 0;
    }
    public Boolean isSingle() {
        return size() == 1;
    }
    public Boolean isDistinct(String field) {
    	Boolean isDistinct = true;
        Map<Object, SObject> sObjMap = new Map<Object, SObject>();
        String[] fieldPath = field.trim().split('[.]');
        for(SObject sObj : l) {
            Object key = getFieldValue(sObj, fieldPath, true);
            if(sObjMap.containsKey(key)) {
                isDistinct = false;
                break;
            } else {
                sObjMap.put(key, sObj);
            }
        }
        return isDistinct;
    }
    public SObjectList reverse() {
        SObjectList reversedList = new SObjectList();
        for(Integer i = l.size() - 1; i >= 0; i--) {
            reversedList.add(l[i]);
        }
        return reversedList;
    }
    public SObjectList take(Integer size) {
        SObjectList sObjList = new SObjectList();
        for(Integer i = 0; i < size && i < l.size(); i++) {
            sObjList.add(l[i]);
        }
        return sObjList;
    }
    public SObjectList take(Integer startIndex, Integer endIndex) {
        SObjectList sObjList = new SObjectList();
        for(Integer i = startIndex; i <= endIndex && i < l.size(); i++) {
            sObjList.add(l[i]);
        }
        return sObjList;
    }
    /*
    public Object sum(String field) {
        Primitives.Value ret = new Primitives.ObjectValue(null);
        for(SObject sObj : l) {
            system.debug('ret.value:'+ret.value);
            ret = ret.value == null ? Primitives.valueOf(getFieldValue(sObj, field, true)) : ret.add(getFieldValue(sObj, field, true));
        }
        return ret.value;
    }
    public Object average(String field) {
        Primitives.Value ret = new Primitives.ObjectValue(null);
        for(SObject sObj : l) {
            ret = ret.value == null ? Primitives.valueOf(getFieldValue(sObj, field, true)) : ret.add(getFieldValue(sObj, field, true));
        }
        System.assert(size() != 0, 'average: List size is 0. Cannot calculate average.');
        ret = ret.divide(new Primitives.IntegerValue(size()));
        return ret.value;
    }
    public Object max(String field) {
        Primitives.Value ret = new Primitives.ObjectValue(null);
        for(SObject sObj : l) {
            ret = ret.value != null && ret.lessThan(getFieldValue(sObj, field, true)) ? ret : Primitives.valueOf(getFieldValue(sObj, field, true));
        }
        return ret.value;
    }
    public Object min(String field) {
        Primitives.Value ret = new Primitives.ObjectValue(null);
        for(SObject sObj : l) {
            ret = ret.value != null && ret.greaterThan(getFieldValue(sObj, field, true)) ? ret : Primitives.valueOf(getFieldValue(sObj, field, true));
        }
        return ret.value;
    }*/
    private Object getFieldValue(SObject sObj, String[] fieldPath, Boolean notQueryParent) {
        Object ret = sObj;
        if(!fieldPath.isEmpty()) {
	        if(fieldPath.size() == 1) {
	            ret = sObj.get(fieldPath[0]);
	        } else {
	            for(Integer i = 0; i < fieldPath.size(); i++) {
	                if(notQueryParent && i == fieldPath.size() - 1) {
	                    ret = ((SObject)ret).get(fieldPath[i]);
	                } else {
	                    ret = ((SObject)ret).getSObject(fieldPath[i]);
	                    if(ret == null) {
	                        break;
	                    }
	                }
	            }
	        }
	    }
        return ret;
    }
    
    public SObjectList whereEq(Bool.Expression expression) {
        SObjectList whereList = new SObjectList();
        for(SObject sObj : l) {
            if(expression.calc(sObj)) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }

    public static List<SObject> whereEq(List<SObject> l, Bool.Expression expression) {
        List<SObject> whereList = new List<SObject>();
        for(SObject sObj : l) {
            if(expression.calc(sObj)) {
                whereList.add(sObj);
            }
        }
        return whereList;
    }
    /* Todo
    public Object aggregate(String field) {
        Primitives.Value ret = new Primitives.ObjectValue(null);
        for(SObject sObj : l) {
            ret = ret.value == null || sObj.getValue(field).lessThan(ret) ? sObj.getValue(field) : ret;
        }
        return ret;
    }
    public SObjectList union(SObjectList another) {
        List<SObject> newList = new List<SObject>();
        newList.addAll(this.original);
        newList.addAll(another.original);
        return new SObjectList(newList);
    }
    public SObjectList except(SObjectList another) {
        List<SObject> newList = new List<SObject>();
        newList.addAll(this.original);
        newList.addAll(another.original);
        return new SObjectList(newList);
    }
    public SObjectList intersect(SObjectList another) {
        List<SObject> newList = new List<SObject>();
        newList.addAll(this.original);
        newList.addAll(another.original);
        return new SObjectList(newList);
    }
    
    */
    // public SObjectList doAction(ILikeActionInvokable action, Map<String, Object> params) {
    //    for(SObject sObj : l) {
    //         action.invoke(sObj, params);
    //     }
    //     return this;
    // }
    
    // public SObjectList doBulkAction(ILikeListActionInvokable action, Map<String, Object> params) {
    //     action.invoke(this, params);
    //     return this;
    // }
}