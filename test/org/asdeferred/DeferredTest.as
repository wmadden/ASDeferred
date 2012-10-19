// Copyright (c) 2012, Pro Medicus
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
package org.asdeferred
{
    import org.asdeferred.Deferred;
    import org.asdeferred.Promise;
    import org.asdeferred.PromiseEvent;
    import org.asdeferred.test.Helpers;
    import org.asdeferred.test.TestBase;
    import org.asdeferred.test.expectations.expectingEvent;

    import flash.events.Event;

    import mockolate.allow;

    import mockolate.arg;
    import mockolate.expect;
    import mockolate.runner.MockolateRule;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItems;
    import org.hamcrest.core.throws;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasPropertyWithValue;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;

    public class DeferredTest extends TestBase
{
    private static const EMPTY_FUNCTION : Function = function (event : Event = null, _ : Object = null) : void
    {
    };

    //------------------------------
    //  instance
    //------------------------------

    private var instance : Deferred;

    //------------------------------

    [Mock()]
    public var promise : Promise;

    //--------------------------------------------------------------------------------------------------------------
    //
    //  Maintenance
    //
    //--------------------------------------------------------------------------------------------------------------

    //------------------------------

    [Rule]
    public var mocks : MockolateRule = new MockolateRule();

    //------------------------------
    //  before
    //------------------------------

    [Before]
    public function before() : void
    {
        instance = new Deferred();
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  Helper Methods
    //
    //--------------------------------------------------------------------------------------------------------------

    private function assertThatEventCarriesArgs(eventName : String, triggerMethodName : String) : void
    {
        var args : Array = [ "some", "arguments", 1, 2, 3 ];

        Async.handleEvent(this, instance, eventName, function (event : PromiseEvent, _ : Object) : void
        {
            Helpers.assertArraysEqual(args, event.args);
        }, 1);

        instance[triggerMethodName].apply(instance, args);
    }

    private function assertThatEventIsDispatchedByMethod(eventName : String, triggerMethodName : String) : void
    {
        Async.proceedOnEvent(this, instance, eventName, 1);
        instance[triggerMethodName]();
    }

    private function assertThatMethodInvokesHandler(handlerMethodName : String, triggerMethodName : String) : void
    {
        var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);
        instance[handlerMethodName](handler);
        instance[triggerMethodName]();
    }

    private function assertThatMethodReturnsInstance(handlerMethodName : String) : void
    {
        assertThat(instance[handlerMethodName](EMPTY_FUNCTION), equalTo(instance));
    }

    private function assertTheObjectEntersCorrectState(triggerMethodName : String, constantName : String) : void
    {
        instance[triggerMethodName]();
        assertThat(instance.state, equalTo(Deferred[constantName]));
    }

    private function assertThatEventIsNotDispatched(firstTriggerMethodName : String, secondTriggerMethodName : String,
                                                    constantName : String) : void
    {
        instance[firstTriggerMethodName]();
        Async.failOnEvent(this, instance, PromiseEvent[constantName], 1);
        instance[secondTriggerMethodName]();
    }

    private function assertThatHandlerIsCalled(initialTrigger : String, handlerMethodName : String) : void
    {
        instance[initialTrigger]();
        var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);
        instance[handlerMethodName](handler);
    }

    private function assertThatAllEventListenersAreRemoved(trigger : String) : void
    {
        instance.addEventListener( PromiseEvent.RESOLVED, EMPTY_FUNCTION );
        instance.addEventListener( PromiseEvent.REJECTED, EMPTY_FUNCTION );
        instance.addEventListener( PromiseEvent.PROGRESS, EMPTY_FUNCTION );

        instance[trigger]();

        assertThat( instance.hasEventListener(PromiseEvent.RESOLVED), isFalse() );
        assertThat( instance.hasEventListener(PromiseEvent.REJECTED), isFalse() );
        assertThat( instance.hasEventListener(PromiseEvent.PROGRESS), isFalse() );
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  addEventListener Tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test(async)]
    public function addEventListenerShouldDoNothingIfTheDeferredHasResolved() : void
    {
        instance.resolve();
        Async.failOnEvent( this, instance, PromiseEvent.RESOLVED, 1 );
        instance.dispatchEvent( new PromiseEvent([], PromiseEvent.RESOLVED) );
    }

    [Test(async)]
    public function addEventListenerShouldDoNothingIfTheDeferredHasRejected() : void
    {
        instance.reject();
        Async.failOnEvent( this, instance, PromiseEvent.REJECTED, 1 );
        instance.dispatchEvent( new PromiseEvent([], PromiseEvent.REJECTED) );
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  Initial state tests
    //
    //--------------------------------------------------------------------------------------------------------------
    [Test()]
    public function initialStateIsPending() : void
    {
        assertThat(instance.state, equalTo(Deferred.PENDING))
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  resolved() and done() tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test(async)]
    public function whenResolvedItShouldDispatchAResolvedEvent() : void
    {
        assertThatEventIsDispatchedByMethod(PromiseEvent.RESOLVED, 'resolve');
    }

    [Test(async)]
    public function resolvedEventShouldCarryArgsPassedToResolveMethod() : void
    {
        assertThatEventCarriesArgs(PromiseEvent.RESOLVED, 'resolve');
    }

    [Test(async)]
    public function doneShouldAddAResolvedEventHandler() : void
    {
        assertThatMethodInvokesHandler('done', 'resolve');
    }

    [Test()]
    public function doneShouldReturnTheDeferred() : void
    {
        assertThatMethodReturnsInstance('done');
    }

    [Test()]
    public function callingResolveShouldPutItInTheResolvedState() : void
    {
        assertTheObjectEntersCorrectState('resolve', 'RESOLVED');
    }

    [Test(async)]
    public function callingResolveWhenAlreadyResolvedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('resolve', 'resolve', 'RESOLVED');
    }

    [Test(async)]
    public function callingResolveWhenRejectedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('reject', 'resolve', 'RESOLVED');
    }

    [Test(async)]
    public function ifDeferredIsResolvedThenDoneShouldImmediatelyExecuteHandler() : void
    {
        instance.resolve();
        assertThatHandlerIsCalled('resolve', 'done');
    }

    [Test(async)]
    public function ifDeferredIsResolvedThenFailShouldExecuteHandlerWithTheArgumentsPassedToResolve() : void
    {
        var args : Array = [ "some", "arguments", 1, 2, 3 ];

        instance.resolve.apply( instance, args );

        var handler : Function = Async.asyncHandler(this, function( event : PromiseEvent, _ : Object ) : void {
            Helpers.assertArraysEqual( args, event.args );
        }, 1);

        instance.done( handler );
    }

    [Test()]
    public function whenResolvedItShouldRemoveAllEventListeners() : void
    {
        assertThatAllEventListenersAreRemoved( 'resolve' );
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  reject() and fail() tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test(async)]
    public function whenRejectedItShouldDispatchARejectedEvent() : void
    {
        assertThatEventIsDispatchedByMethod(PromiseEvent.REJECTED, 'reject');
    }

    [Test(async)]
    public function rejectedEventShouldCarryArgsPassedToRejectMethod() : void
    {
        assertThatEventCarriesArgs(PromiseEvent.REJECTED, 'reject');
    }

    [Test(async)]
    public function failShouldAddARejectedEventHandler() : void
    {
        assertThatMethodInvokesHandler('fail', 'reject');
    }

    [Test()]
    public function failShouldReturnTheDeferred() : void
    {
        assertThatMethodReturnsInstance('fail');
    }

    [Test()]
    public function callingRejectShouldPutItInTheRejectedState() : void
    {
        assertTheObjectEntersCorrectState('reject', 'REJECTED');
    }

    [Test(async)]
    public function callingRejectWhenAlreadyRejectedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('reject', 'reject', 'REJECTED');
    }

    [Test(async)]
    public function callingRejectWhenResolvedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('resolve', 'reject', 'REJECTED');
    }

    [Test(async)]
    public function ifDeferredIsRejectedThenFailShouldImmediatelyExecuteHandler() : void
    {
        instance.reject();
        assertThatHandlerIsCalled('reject', 'fail');
    }

    [Test(async)]
    public function ifDeferredIsRejectedThenFailShouldExecuteHandlerWithTheArgumentsPassedToReject() : void
    {
        var args : Array = [ "some", "arguments", 1, 2, 3 ];

        instance.reject.apply( instance, args );

        var handler : Function = Async.asyncHandler(this, function( event : PromiseEvent, _ : Object ) : void {
            Helpers.assertArraysEqual( args, event.args );
        }, 1);

        instance.fail( handler );
    }

    [Test()]
    public function whenRejectedItShouldRemoveAllEventListeners() : void
    {
        assertThatAllEventListenersAreRemoved( 'reject' );
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  notify() and progress() tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test(async)]
    public function whenNotifiedItShouldDispatchAProgressEvent() : void
    {
        assertThatEventIsDispatchedByMethod(PromiseEvent.PROGRESS, 'notify');
    }

    [Test(async)]
    public function progressEventShouldCarryArgsPassedToNotifyMethod() : void
    {
        assertThatEventCarriesArgs(PromiseEvent.PROGRESS, 'notify');
    }

    [Test(async)]
    public function progressShouldAddAProgressEventHandler() : void
    {
        assertThatMethodInvokesHandler('progress', 'notify');
    }

    [Test()]
    public function progressShouldReturnTheDeferred() : void
    {
        assertThatMethodReturnsInstance('progress');
    }

    [Test(async)]
    public function callingNotifyWhenResolvedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('resolve', 'notify', 'PROGRESS');
    }

    [Test(async)]
    public function callingNotifyWhenRejectedShouldNotDispatchAnEvent() : void
    {
        assertThatEventIsNotDispatched('reject', 'notify', 'PROGRESS');
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  then() tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test(async)]
    public function thenShouldFireWhenResolved() : void
    {
        assertThatMethodInvokesHandler('then', 'resolve');
    }

    [Test(async)]
    public function thenShouldFireWhenRejected() : void
    {
        assertThatMethodInvokesHandler('then', 'resolve');
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  when() tests
    //
    //--------------------------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------------------------
    //
    //  decidedBy() tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test()]
    public function whenDecidedByADeferredIfTheDeferredIsRejectedItShouldReject() : void
    {
        var operation : Deferred = new Deferred();

        instance.decidedBy(operation);
        operation.reject();

        assertThat(instance.state, equalTo(Deferred.REJECTED));
    }

    [Test()]
    public function whenDecidedByADeferredIfTheDeferredIsResolvedItShouldResolve() : void
    {
        var operation : Deferred = new Deferred();

        instance.decidedBy(operation);
        operation.resolve();

        assertThat(instance.state, equalTo(Deferred.RESOLVED));
    }

    [Test(async)]
    public function whenDecidedByADeferredIfTheDeferredIsRejectedItShouldRejectWithTheSameArguments() : void
    {
        var operation : Deferred = new Deferred();
        var args : Array = [1,2,3,"abc"];
        var handler : Function = Async.asyncHandler(this, function(event : PromiseEvent, _ : Object) : void
        {
            Helpers.assertArraysEqual(args, event.args);
        }, 1)

        instance.fail( handler );
        instance.decidedBy(operation);

        operation.reject.apply(operation, args);
    }

    [Test(async)]
    public function whenDecidedByADeferredIfTheDeferredIsResolvedItShouldResolveWithTheSameArguments() : void
    {
        var operation : Deferred = new Deferred();
        var args : Array = [1,2,3,"abc"];
        var handler : Function = Async.asyncHandler(this, function(event : PromiseEvent, _ : Object) : void
        {
            Helpers.assertArraysEqual(args, event.args);
        }, 1)

        instance.done( handler );
        instance.decidedBy(operation);

        operation.resolve.apply(operation, args);
    }

    [Test()]
    public function decidedByShouldReturnSelfSoWeCanChainOperationsOnIt() : void
    {
        var operation : Promise = new Deferred();
        assertThat(instance.decidedBy(operation), equalTo(instance));
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  State Getter Tests
    //
    //--------------------------------------------------------------------------------------------------------------

    [Test()]
    public function isPendingShouldBeTrueIfTheDeferredIsPending() : void
    {
        assertThat(instance.isPending, equalTo(true));
    }

    [Test()]
    public function isPendingShouldBeFalseIfTheDeferredIsRejected() : void
    {
        instance.reject()
        assertThat(instance.isPending, equalTo(false));
    }

    [Test()]
    public function isPendingShouldBeFalseIfTheDeferredIsResolved() : void
    {
        instance.resolve()
        assertThat(instance.isPending, equalTo(false));
    }

    [Test()]
    public function isResolvedShouldBeTrueIfTheDeferredIsResolved() : void
    {
        instance.resolve()
        assertThat(instance.isResolved, equalTo(true));
    }

    [Test()]
    public function isResolvedShouldBeFalseIfTheDeferredIsPending() : void
    {
        assertThat(instance.isResolved, equalTo(false));
    }

    [Test()]
    public function isResolvedShouldBeFalseIfTheDeferredIsRejected() : void
    {
        instance.reject()
        assertThat(instance.isResolved, equalTo(false));
    }


    [Test()]
    public function isRejectedShouldBeTrueIfTheDeferredIsRejected() : void
    {
        instance.reject()
        assertThat(instance.isRejected, equalTo(true));
    }

    [Test()]
    public function isRejectedShouldBeFalseIfTheDeferredIsNotRejected() : void
    {
        assertThat(instance.isRejected, equalTo(false));
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  timeoutAfter
    //
    //--------------------------------------------------------------------------------------------------------------

    //------------------------------

    [Test(async)]
    public function timeoutShouldDoNothingUnlessItsPending() : void
    {
        instance.resolve();
        instance.timeoutAfter(1);
        Async.failOnEvent(this, instance, PromiseEvent.REJECTED,100);
    }

    //------------------------------

    [Test(async)]
    public function timeoutAfterShouldRejectTheDeferredAfterTheTimeoutExpires() : void
    {
        Async.proceedOnEvent(this, instance, PromiseEvent.REJECTED);
        instance.timeoutAfter(1);
    }

    //------------------------------

    [Test(async)]
    public function timeoutAfterShouldThrowAnErrorIfItsAlreadyBeenCalled() : void
    {
        instance.timeoutAfter(1);
        assertThat(function () : void
                   {
                       instance.timeoutAfter(2)
                   }, throws(instanceOf(Error)));
    }

    //------------------------------

    [Test(async)]
    public function timeoutShouldNotRejectIfItsResolvedWithinTheTimeout() : void
    {
        Async.failOnEvent(this, instance, PromiseEvent.REJECTED,100);
        instance.timeoutAfter(1);
        instance.resolve();
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  chain()
    //
    //--------------------------------------------------------------------------------------------------------------

    //------------------------------

    [Test(async, ui)]
    public function chainShouldReturnAPromise() : void
    {
        assertThat(instance.chain(), instanceOf(Promise));
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheDeferredFailsTheChainShouldFail() : void
    {
        var chainPromise : Promise = instance.chain();

        instance.reject();

        assertThat(chainPromise.isRejected);
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheDeferredFailsTheChainShouldFailWithTheSameArguments() : void
    {
        var chainPromise : Promise = instance.chain();

        declare(
            expectingEvent(PromiseEvent.REJECTED)
                .from(chainPromise)
                .that(hasPropertyWithValue('args', [0, '1', true]))
        );

        instance.reject(0, '1', true);
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheDeferredResolvesAndTheChainIsEmptyItShouldResolve() : void
    {
        var chainPromise : Promise = instance.chain();

        instance.resolve();

        assertThat(chainPromise.isResolved);
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheDeferredResolvesChainShouldCallTheFirstOperation() : void
    {
        var firstOperationWasCalled : Boolean = false;
        var firstOperation : Function = function () : Promise
        {
            firstOperationWasCalled = true;
            return new Deferred();
        };

        instance.chain(firstOperation);

        instance.resolve();

        assertThat(firstOperationWasCalled);
    }

    //------------------------------

    [Test(async, ui)]
    public function chainShouldCallTheFirstOperationWithTheArgumentsTheDeferredWasResolvedWith() : void
    {
        var firstOperationWasCalled : Boolean = false;
        var firstOperationArgs : Array;
        var firstOperation : Function = function (...args) : Promise
        {
            firstOperationWasCalled = true;
            firstOperationArgs = args;
            return new Deferred();
        };

        instance.chain(firstOperation);

        instance.resolve(0, "1", true);

        assertThat(firstOperationWasCalled);
        assertThat(firstOperationArgs, hasItems(0, "1", true));
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheDeferredResolvesItShouldChainTheRemainingOperationsOntoTheFirstOperation() : void
    {
        var firstOperation : Function = function () : Promise
        {
            return promise;
        };

        var secondOperation : Function = function () : * { return new Deferred(); };
        var thirdOperation : Function = function () : * { return new Deferred(); };

        instance.chain(firstOperation, secondOperation, thirdOperation);
        expect(promise.chain(arg(secondOperation), arg(thirdOperation))).returns(new Deferred());

        instance.resolve();
    }
    
    //------------------------------

    [Test(async, ui)]
    public function whenTheRestOfTheChainFailsTheChainShouldFail() : void
    {
        var firstOperation : Function = function () : Promise
        {
            return promise;
        };

        var chainPromise : Promise = instance.chain(firstOperation);

        // This test is a little inelegant because we rely on other functions rather than stubbing them out, but it's
        // much easier. Really here we're testing that decidedBy() works, which sucks, but I can't think of a better way
        // of doing it.

        var restOfChainPromise : Deferred = new Deferred();
        allow(promise.chain()).returns(restOfChainPromise);

        instance.resolve();
        restOfChainPromise.reject();

        assertThat(chainPromise.isRejected);
    }

    //------------------------------

    [Test(async, ui)]
    public function whenTheRestOfTheChainSucceedsTheChainShouldSucceed() : void
    {
        var firstOperation : Function = function () : Promise
        {
            return promise;
        };

        var chainPromise : Promise = instance.chain(firstOperation);

        var restOfChainPromise : Deferred = new Deferred();
        allow(promise.chain()).returns(restOfChainPromise);

        instance.resolve();
        restOfChainPromise.resolve();

        assertThat(chainPromise.isResolved);
    }

    //------------------------------

    [Test(async, ui)]
    public function whenAnOperationRejectsTheChainPromiseShouldRejectWithTheSameArguments() : void
    {
        var firstOperation : Function = function () : Promise
        {
            return new Deferred().reject(0, '1', true);
        };
        var secondOperation : Function = function () {};

        var chainPromise : Promise = instance.chain(firstOperation, secondOperation);

        declare(
            expectingEvent(PromiseEvent.REJECTED)
                .from(chainPromise)
                .that(hasPropertyWithValue('args', hasItems(0, '1', true)))
        );

        instance.resolve();
    }

    //------------------------------

    [Test(async, ui)]
    public function whenAllOperationsResolveTheChainPromiseShouldResolveWithTheSameArgumentsAsTheLastOperation() : void
    {
        var firstOperation : Function = function () : Promise
        {
            return new Deferred().resolve(0, '1', true);
        };

        var chainPromise : Promise = instance.chain(firstOperation);

        declare(
            expectingEvent(PromiseEvent.RESOLVED)
                .from(chainPromise)
                .that(hasPropertyWithValue('args', hasItems(0, '1', true)))
        );

        instance.resolve();
    }
}
}
