---
layout: post
title: "Mockito cheat sheet"
category: code
tags: [mockito, java]
---
{% include JB/setup %}

I have been using Mockito for a project recently and made a cheat sheet that is meant to be easy to digest.

First things first, stop and think if you really need ot use a mocking framework. 

<!--more-->

To spy or to Mock.
------------------

A mock: no implementation at all, just a shell.

A spy: hooking into a real object, unless you specify anything else the object will behave as normal.

### Usage:
Normal usage is with the static methods on Mockito (you can of cause use static import for these).

    SomeClass mock = Mockito.mock(SomeClass.class);
    SomeClass spy = Mockito.spy(new SomeClass());

Mockito can also be used with annotations, you just need to use the JUnit runner.

    @RunWith(MockitoJUnitRunner.class)
    class MyTestClass {
      @Mock
      SomeClass mock2;
      @Spy 
      SomeClass spy2 = new SomeClass();
    }

Mocking you(r methods)
----------------------

### Methods with return types

Here we are mocking the `List<String> fetch` method of the mock2 object.

    //Our mock return value:
    List<String> mockResult = Arrays.asList("result1","result2";"result3");
    
    //Here we are using the any matchers.
    Mockito.when(
      mock2.fetch(
        Mockito.any(credentials.getClass()), 
        Mockito.anyBoolean(), 
        Mockito.anyString()
      )).thenReturn(mockResult);
    
    //Using specific values
    Mockito.when(mock2.fetch(credentials, true, "foo")).thenReturn(mockResult);
    
    //Mixing specifics and "wildcards"
    Mockito.when(
      mock2.fetch(
        Mockito.eq(credentials), 
        Mockito.eq(true), 
        Mockito.anyString()
      )).thenReturn(mockResult);

As you can see if you want to mix matchers and specifics you need to use the `Mockito.eq` wrapper.

You can also make the method throw exceptions:

    Mockito.when(mock2.fetch(credentials, true, "foo"))
      .thenThrow(new IllegalArgumentException());

### Enter the void methods

When mocking void methods, you normally don't have to do anything. 
But you might want to test exception handling from a void method.

Here we are mocking the void method `spy2.logError(String message)`.

    //Using matchers
    Mockito.doThrow(new IllegalArgumentException())
      .when(spy2).logError(Mockito.anyString());
    
    //Make the method do nothing
    Mockito.doNothing().when(spy2).logError(Mockito.anyString());

Verifying
---------

You can also use mockito for verifying if a method was called, how many times it was called and with which parameters. 
This is usefull for verifying that some class actually uses a 

    //throws exception if fetch was not called with the specific arguments
    Mockito.verify(spy).fetch(credentials, true, "foo")

Other tips and tricks
---------------------

### Create helper methods

If you need to mock a specific method multiple times you might want to make a helper method.

    private OngoingStubbing<List<String>> mockFetch(SomeClass toMock){
      return Mockito.when(
      toMock.fetch(
        Mockito.any(credentials.getClass()), 
        Mockito.anyBoolean(), 
        Mockito.anyString()
      ));
    }

You can then use this method to quickly setup different return values or throwing different exceptions.

    //Example usage
    mockFetch(mock2).thenReturn(new ArrayList<String>());

### Resources

Another good, and still simple article to read would be: http://www.vogella.com/tutorials/Mockito/article.html
