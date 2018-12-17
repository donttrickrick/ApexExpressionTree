
# Apex Expression Tree
This repo is built to support boolean lambda expression for SObject.

So, instead of directly running plain code
`a == 'str' && b != null`, 
Lambda expression go first with building expression 
`expression = Bool.and(Bool.eq('a', 'str'), Bool.notEq('b', 'null'))`
then invoking anywhere by 
`expression.calc();`

## Dev and Test
> Not going to continue developing this repo because of Salesforce's poor performance of dynamic syntax and static functions. Specified as below.
### Performance Test
#### 1) Static Syntax VS Dynamic Syntax
Static syntax is more than 7 times faster than dynamic syntax. Please use below Code snipet to verify this by yourself.
```Java
// Static Syntax
Account acc = new Account();
acc.Name = 'Goodman';
Boolean isEq = null;
Datetime startTime = Datetime.now();
for(Integer i =  0; i <  10000; i++) {
    isEq = acc.Name == 'Good';
}
Datetime endTime = Datetime.now();
System.debug('***Static Time: '  + (endTime.millisecond() - startTime.millisecond())); // 50ms

// Dynamic Syntax
startTime = Datetime.now();
for(Integer i =  0; i <  10000; i++) {
    isEq = acc.get('Name') == 'Good';
}
endTime = Datetime.now();
System.debug('***Dynamic Time: '  + (endTime.millisecond() - startTime.millisecond())); // 481ms
```
#### 2) Plain Code VS Static Function & Function in Class
Plain code is 6 to 10 times faster than static function. Static function is the same with functions in class.
```Java
// Plain Code
Account acc = new Account();
acc.Name = 'Goodman';
Boolean isEq = null;
Datetime startTime = Datetime.now();
for(Integer i =  0; i <  10000; i++) {
    isEq = acc.Name == 'Good';
}
Datetime endTime = Datetime.now();
System.debug('***Plain Code Time: '  + (endTime.millisecond() - startTime.millisecond())); // 41ms

// Static Function
startTime = Datetime.now();
for(Integer i =  0; i <  10000; i++) {
    isEq = eq(acc.Name, 'Good');
}
endTime = Datetime.now();
System.debug('***Static Function Time: '  + (endTime.millisecond() - startTime.millisecond())); // 266ms
public static Boolean eq(Object a, Object b) {
    return a == b;
}

// Function in Class
startTime = Datetime.now();
Eq eqFunc = new Eq();
for(Integer i =  0; i <  10000; i++) {
    isEq = eqFunc.calc(acc.Name, 'Good'); 
}
endTime = Datetime.now();
System.debug('***Function in Class Time: '  + (endTime.millisecond() - startTime.millisecond())); // 258ms
public class Eq {
    public Boolean calc(Object a, Object b) {
        return a == b;
    }
}
```
> If you still want to know how to use this repo or you want to see performance test result for this repo, please check here:
[ExpressTreePerformanceTest](https://github.com/donttrickrick/ApexExpressionTree/blob/master/force-app/main/default/classes/ExpTreePerformanceTest.cls)
## **Takeaway**
1) Dynamic syntax badly impacts performance. Do not use dynamic syntax. 
eg. sobject.get(), sobject.getSObject(), sobject.getSObjects()
2) Even static function impact performance. Do not wrap simple logic in any functions.
In real scenario we don't invoke 10000 functions in one single transaction. But it is still possible if we wrap simple logic.
