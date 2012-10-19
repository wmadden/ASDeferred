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
package au.com.promedicus.async
{
    import au.com.promedicus.async.Deferred;
    import au.com.promedicus.async.Promise;
    import au.com.promedicus.async.chain;

    import mockolate.allow;

    import mockolate.arg;
    import mockolate.expect;

    import mockolate.runner.MockolateRule;

    import org.hamcrest.assertThat;
    import org.hamcrest.core.throws;
    import org.hamcrest.object.equalTo;

    public class chainTest
    {
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

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Tests
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        [Test(async, ui)]
        public function chainShouldCallTheFirstOperation() : void
        {
            var firstOperationWasCalled : Boolean = false;
            var firstOperation : Function = function ()
            {
                firstOperationWasCalled = true;
                return promise;
            };

            chain(firstOperation);

            assertThat(firstOperationWasCalled);
        }

        //------------------------------

        [Test(async, ui)]
        public function chainShouldThrowAnErrorIfTheOperationDoesntReturnAPromise() : void
        {
            var firstOperation : Function = function ()
            {
            };

            assertThat(function ()
                       {
                           chain(firstOperation);
                       }, throws(Error));
        }

        //------------------------------

        [Test(async, ui)]
        public function chainShouldChainTheRemainingOperationsOntoThePromiseReturnedFromTheFirstOperation() : void
        {
            var firstOperation : Function = function ()
            {
                return promise;
            };
            var secondOperation : Function = function ()
            {
            };
            var thirdOperation : Function = function ()
            {
            };

            expect(promise.chain(arg(secondOperation), arg(thirdOperation)));

            chain(firstOperation, secondOperation, thirdOperation);
        }

        //------------------------------

        [Test(async, ui)]
        public function chainShouldReturnTheResultPromise() : void
        {
            var firstOperation : Function = function ()
            {
                return promise;
            };
            var chainPromise : Promise = new Deferred();

            allow(promise.chain()).returns(chainPromise);

            assertThat(chain(firstOperation), equalTo(chainPromise));
        }
    }
}
