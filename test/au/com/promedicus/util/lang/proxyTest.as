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
package au.com.promedicus.util.lang
{
    import au.com.promedicus.test.Helpers;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;

    public class proxyTest
    {

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Tests
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        [Test()]
        public function whenTheProxyIsCalledItShouldCallTheOriginalFunctionWithTheGivenContext() : void
        {
            var wrappedFunction : Function = function() {
                assertThat( this, equalTo(context) );
            };
            var context : Object = {};

            var proxyFunction : Function = proxy( context, wrappedFunction );

            proxyFunction();
        }

        //------------------------------

        [Test()]
        public function whenTheProxyIsCalledItShouldCallTheOriginalFunctionWithTheOriginalArguments() : void
        {
            var expectedArgs : Array = [1,2,3,"abc"];
            var wrappedFunction : Function = function (...args) {
                Helpers.assertArraysEqual(args, expectedArgs)
            };
            var context : Object = {};

            var proxyFunction : Function = proxy( context, wrappedFunction );

            proxyFunction.apply(this, expectedArgs);
        }

        //------------------------------

        [Test()]
        public function whenTheProxyIsCalledItShouldReturnTheResultOfTheWrappedFunction() : void
        {
            var expectedResult : Object = { hello: 'world' };
            var wrappedFunction : Function = function() {
                return expectedResult;
            };
            var context : Object = {};

            var proxyFunction : Function = proxy( context, wrappedFunction );

            assertThat(proxyFunction(), equalTo(expectedResult));
        }

    }
}
