// D is for dynamic
public class DCase {
    public final static SObjectField.Getable subject = new Subject();
    public final static SObjectField.Getable contactAccountType = new ContactAccountType();
    public final static SObjectField.Getable isCustomerCase = new IsCustomerCase();
    public final static SObjectField.Getable isPartnerHolidayCase = new IsPartnerHolidayCase();
	
    public class IsPartnerHolidayCase implements SObjectField.Getable {
        private IsPartnerHolidayCase() {}
        public Object get(SObject sObj) {
            Case oneCase = (Case)sObj;
            return oneCase.Subject == 'Holiday' && oneCase.Contact.Account.Type != 'Customer';
        }
    }
    public class IsCustomerCase implements SObjectField.Getable {
        private IsCustomerCase() {}
        public Object get(SObject sObj) {
            return ((case)sObj).Contact.Account.Type == 'Customer';
        }
    }
    public class Subject implements SObjectField.Getable {
        private Subject() {}
        public Object get(SObject sObj) {
            return ((case)sObj).Subject;
        }
    }
    public class ContactAccountType implements SObjectField.Getable {
        private ContactAccountType() {}
        public Object get(SObject sObj) {
            return ((case)sObj).Contact.Account.Type;
        }
    }
    

}