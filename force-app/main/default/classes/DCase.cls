// D is for dynamic
public class DCase {
    public static SObjectField.Getable dSubject = new dSubject();
    public static SObjectField.Getable dContactAccountType = new dContactAccountType();

    public class dSubject implements SObjectField.Getable {
        private dSubject() {}
        public Object get(SObject sObj) {
            return ((case)sObj).Subject;
        }
    }
    public class dContactAccountType implements SObjectField.Getable {
        private dContactAccountType() {}
        public Object get(SObject sObj) {
            return ((case)sObj).Contact.Account.Type;
        }
    }
    

}