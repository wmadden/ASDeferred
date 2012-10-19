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
    import org.asdeferred.when;

    import flash.events.Event;

    import org.flexunit.async.Async;

    import org.hamcrest.assertThat;
    import org.hamcrest.core.isA;

    import org.hamcrest.object.notNullValue;

    public class whenTest
    {
        private static const EMPTY_FUNCTION : Function = function (event : Event = null, _ : Object = null) : void
        {
        };

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Tests
        //
        //--------------------------------------------------------------------------------------------------------------

        [Test()]
        public function whenMethodShouldReturnANewDeferred() : void
        {
            var result : Object = when();

            assertThat(result, notNullValue());
            assertThat(result, isA(Promise));
        }

        [Test(async)]
        public function whenShouldProduceADeferredObjectThatResolvesWhenAllOfItsArgumentsResolve() : void
        {
            var deferred1 : Deferred = new Deferred();
            var deferred2 : Deferred = new Deferred();
            var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);

            var whenDeferred : Deferred = when(deferred1, deferred2) as Deferred;
            whenDeferred.done(handler);

            deferred2.resolve();
            deferred1.resolve();
        }

        [Test(async)]
        public function whenShouldProduceADeferredObjectThatsRejectedIfAnyOfItsArgumentsAreRejected() : void
        {
            var deferred1 : Deferred = new Deferred();
            var deferred2 : Deferred = new Deferred();
            var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);

            var whenDeferred : Deferred = when(deferred1, deferred2) as Deferred;
            whenDeferred.fail(handler);

            Async.failOnEvent( this, whenDeferred, PromiseEvent.RESOLVED, 1 );

            deferred2.resolve();
            deferred1.reject();
        }

        [Test(async)]
        public function whenShouldOperateCorrectlyIfItsDeferredsHaveAlreadyResolved() : void
        {
            var deferred1 : Deferred = new Deferred();
            var deferred2 : Deferred = new Deferred();
            var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);

            deferred2.resolve();
            deferred1.resolve();

            var whenDeferred : Deferred = when(deferred1, deferred2) as Deferred;
            whenDeferred.done(handler);
        }

        [Test(async)]
        public function whenShouldOperateCorrectlyIfItsDeferredsHaveAlreadyRejected() : void
        {
            var deferred1 : Deferred = new Deferred();
            var deferred2 : Deferred = new Deferred();
            var handler : Function = Async.asyncHandler(this, EMPTY_FUNCTION, 1);

            deferred2.resolve();
            deferred1.reject();

            var whenDeferred : Deferred = when(deferred1, deferred2) as Deferred;
            whenDeferred.fail(handler);
        }
    }
}
