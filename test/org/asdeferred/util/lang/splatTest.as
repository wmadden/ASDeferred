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
package org.asdeferred.util.lang
{
    import org.asdeferred.test.TestBase;
    import org.asdeferred.util.lang.*;

    import org.hamcrest.assertThat;

    import org.hamcrest.object.equalTo;

    public class splatTest extends TestBase
    {

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Tests
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        [Test(async)]
        public function splatShouldApplyTheGivenFunction() : void
        {
            var f : Function = expectingToBeCalled();
            splat(f, ["hello world!", 1337, new Date(1987, 7, 14)]);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithTheGivenListOfArguments() : void
        {
            var expectedArgs : Array = ['hello world!', 1337, new Date(1987, 7, 14), false, {hello: 'world!'}];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOf5Arguments() : void
        {
            var expectedArgs : Array = ['hello world!', 1337, new Date(1987, 7, 14), false, {hello: 'world!'}];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOf4Arguments() : void
        {
            var expectedArgs : Array = [1337, new Date(1987, 7, 14), false, {hello: 'world!'}];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOf3Arguments() : void
        {
            var expectedArgs : Array = [new Date(1987, 7, 14), false, {hello: 'world!'}];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOf2Arguments() : void
        {
            var expectedArgs : Array = [false, {hello: 'world!'}];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOf1Arguments() : void
        {
            var expectedArgs : Array = [
                {hello: 'world!'}
            ];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldCallTheFunctionWithAListOfNoArguments() : void
        {
            var expectedArgs : Array = [];

            var f : Function = expectingToBeCalled(function (... args) : void
                                                   {
                                                       assertThat(args, equalTo(expectedArgs));
                                                   });

            splat(f, expectedArgs);
        }

        //------------------------------

        [Test(async)]
        public function splatShouldReturnTheValueOfTheCalledFunction() : void
        {
            var expectedValue : Object = { ima: 'thing' };
            var f : Function = function () : Object
            {
                return expectedValue;
            }

            assertThat(splat(f, []), equalTo(expectedValue));
        }

    }

}