@isTest
public class ExpTreePerformanceTest {
    public static String randomString(String[] candidates) {
        Integer modSize = candidates.size();
        Integer randIndex = Math.mod(Math.round((Math.random() * 50000)), modSize);
        return candidates[randIndex];
    }

    public static Integer randomInteger(Integer min, Integer max) {
        Integer range = max - min;
        Integer randOffset = Math.round(Math.random() * range);
        return min + randOffset;
    }

    @testSetup
    public static void setup() {
        SObjectUnitOfWork uow = new SObjectUnitOfWork();

        // #region setting size and random optional value
        Integer accountSize = 10;
        Integer contactSize = 200;
        Integer caseSize = 200;

        String[] accountNameArray = new String[] {
            'Facebook', 'Apple', 'Netflix', 'Google', 'Tesla'
        };
        String[] accountTypeArray = new String[] {
            'Customer', 'Partner'
        };
        String[] contactFirstNameArray = new String[] {
            'Maurita', 'Bridgett', 'Kari', 'Starr', 'Devona', 'Shaun', 'Ulysses', 'Emanuel', 'Andree', 'Tona', 'Derick', 'Myrl', 'Ardis', 'Serena', 'Shona', 'Joan'
        };
        String[] contactLastNameArray = new String[] {
            'Caples', 'Lavery', 'Hodson', 'Shires', 'Switzer', 'Classen', 'Herrod', 'Klock', 'Kubiak', 'Brant', 'Hartgrove', 'Seitz', 'Hamsher', 'Gallow', 'Kunze', 'Largent'
        };
        String[] caseSubjectArray = new String[] {
            'Application', 'Holiday', 'Vacation', 'Business Travel'
        };
        // #endregion

        for(Integer i = 0; i < accountSize; i++) {
            uow.registerInsert(new Account(Name = randomString(accountNameArray), NumberOfEmployees = randomInteger(50, 100), Type = randomString(accountTypeArray)));
        }
        for(Integer i = 0; i < contactSize; i++) {
            Contact oneContact = new Contact(FirstName = randomString(contactFirstNameArray), LastName = randomString(contactLastNameArray));
            uow.registerInsert(oneContact);
            uow.bindRelationship(oneContact, uow.getInsertList('Account')[randomInteger(0, accountSize - 1)], 'AccountId');
        }
        for(Integer i = 0; i < caseSize; i++) {
            Case oneCase = new Case(Subject = randomString(caseSubjectArray));
            uow.registerInsert(oneCase);
            SObject oneContact = uow.getInsertList('Contact')[randomInteger(0, contactSize - 1)];
            uow.bindRelationship(oneCase, oneContact, 'ContactId');
        }
        uow.commitWork();
    }

    // #region performance test
    @isTest
    public static void testWhereWithPlainCode() {
        List<Case> allCaseList = [SELECT Id, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Account.NumberOfEmployees, Contact.Account.Type, Subject FROM Case];

        Datetime startTime = Datetime.now();
        List<Case> customerCaseList = new List<Case>();
        for(Case oneCase : allCaseList) {
            if(oneCase.Subject == 'Holiday' /*&& oneCase.Contact.Account.Type != 'Customer'*/) {
                customerCaseList.add(oneCase);
            }
        }
        Datetime endTime = Datetime.now();
        Integer elapsedTime = endTime.millisecond() - startTime.millisecond();
        System.debug('Plain Code - Elapsed time: ' + elapsedTime);
        // System.debug('customerCaseList.size(): ' + customerCaseList.size());
    }
    @isTest
    public static void testWhereWithSObjectList() {
        List<Case> allCaseList = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Account.NumberOfEmployees, Contact.Account.Type, Subject FROM Case];

        Datetime startTime = Datetime.now();
        List<SObject> customerCaseList = new SObjectList(allCaseList).whereNotEq('Contact.Account.Type', 'Customer').whereEq('Subject', 'Holiday').toList();
        
        Datetime endTime = Datetime.now();
        Integer elapsedTime = endTime.millisecond() - startTime.millisecond();
        System.debug('SObjectList - Elapsed time: ' + elapsedTime);
        // System.debug('customerCaseList.size(): ' + customerCaseList.size());
    }
    @isTest
    public static void testWhereWithBoolDynamic() {
		List<Case> allCaseList = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Account.NumberOfEmployees, Contact.Account.Type, Subject FROM Case];

        Datetime startTime = Datetime.now();
        // List<SObject> customerCaseList = new SObjectList(allCaseList).whereEq('Contact.Account.Type', 'Customer').toList();
        List<SObject> customerCaseList = new SObjectList(allCaseList).whereEq(
            Bool.andd(new List<Bool.Expression> {
                Bool.notEq(SObjectField.compile('Contact.Account.Type'), 'Customer'), 
                Bool.eq(SObjectField.compile('Subject'), 'Holiday')
            })).toList();
        
        Datetime endTime = Datetime.now();
        Integer elapsedTime = endTime.millisecond() - startTime.millisecond();
        System.debug('Bool Dynamic - Elapsed time: ' + elapsedTime);
        // System.debug('customerCaseList.size(): ' + customerCaseList.size());
    }
    @isTest
    public static void testWhereWithBoolStatic() {
		List<Case> allCaseList = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Account.NumberOfEmployees, Contact.Account.Type, Subject FROM Case];

        Datetime startTime = Datetime.now();
        // List<SObject> customerCaseList = new SObjectList(allCaseList).whereEq('Contact.Account.Type', 'Customer').toList();
        // 
        Bool.Expression expression = Bool.andd(new List<Bool.Expression> {
                Bool.notEq(DCase.dContactAccountType, 'Customer'), 
                Bool.eq(DCase.dSubject, 'Holiday')
            });
        
        // Bool.Expression expression = Bool.eq(DCase.dSubject, 'Holiday');
        
        Datetime endTime1 = Datetime.now();
        Integer elapsedTime1 = endTime1.millisecond() - startTime.millisecond();
        System.debug('Bool Static - Elapsed time 1: ' + elapsedTime1);
        
        List<SObject> customerCaseList = new SObjectList(allCaseList).whereEq(expression);
        
		// Bool.Expression expression = Bool.andd(new List<Bool.Expression> {
        //         Bool.notEq(DCase.dContactAccountType, 'Customer'), 
        //         Bool.eq(DCase.dSubject, 'Holiday')
        //     });
        // List<SObject> whereList = new List<SObject>();
        // for(SObject sObj : allCaseList) {
        //     if(expression.calc(sObj)) {
        //         whereList.add(sObj);
        //     }
        // }
        
        Datetime endTime = Datetime.now();
        Integer elapsedTime = endTime.millisecond() - endTime1.millisecond();
        System.debug('Bool Static - Elapsed time 2: ' + elapsedTime);
        // System.debug('customerCaseList.size(): ' + customerCaseList.size());
    }
    // #endregion
}