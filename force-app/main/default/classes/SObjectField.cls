public without sharing class SObjectField {
    public static Callable2 getSObject = new GetSObjectFunc();
    public static Callable2 get = new GetFunc();
    
	private SObjectField() {}

    // #region core abstract structure
    public interface Getable {
        Object get(SObject sObj); // return SObject or Primitives
    }
    public abstract class Node implements Getable {
        public Node predecessor;
        public String field;
        public virtual Object get(SObject sObj) { return null; }
    }
    // #endregion

    // #region list node, decorator pattern
    public class GetSObjectNode extends Node implements Getable { 
        public override Object get(SObject sObj) {
            SObject parent = predecessor != null ? (SObject)predecessor.get(sObj) : sObj;
            Object ret = null;
            if(parent != null) {
                ret = SObjectField.getSObject.call(parent, field);
            }
            return ret;
        }
    }
    public class GetNode extends Node implements Getable {
        public override Object get(SObject sObj) {
           	SObject parent = predecessor != null ? (SObject)predecessor.get(sObj) : sObj;
            Object ret = null;
            if(parent != null) {
                ret = SObjectField.get.call(parent, field);
            }
            return ret;
        }
    }
    // #endregion
	public static Node compile(String field) {
        return compile(field, true);
    }
	public static Node compile(String field, Boolean notQueryParent) {
		SObjectField.Node tail = null;
        String[] fieldPath = field.trim().split('[.]');
        if(!fieldPath.isEmpty()) {
            for(Integer i = 0; i < fieldPath.size(); i++) {
                SObjectField.Node predecessor = tail;
                if(notQueryParent && i == fieldPath.size() - 1) {
                    tail = new GetNode();
                    tail.predecessor = predecessor;
                    tail.field = fieldPath[i];
                } else {
                    tail = new GetSObjectNode();
                    tail.predecessor = predecessor;
                    tail.field = fieldPath[i];
                }
            }
	    }
        return tail;
	}

    // #region funcs for get sobject field value, all are singleton
	public class GetSObjectFunc implements Callable2 {
        private GetSObjectFunc() {}
		public Object call(Object sObj, Object field) {
			return ((SObject)sObj).getSObject((String)field);
		}
	}
	public class GetFunc implements Callable2 {
        private GetFunc() {}
		public Object call(Object sObj, Object field) {
			return ((SObject)sObj).get((String)field);
		}
	}
    // #endregion
}