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
package org.asdeferred.test
{
    import org.asdeferred.test.expectations.chaining.ExpectationChainable;

    import flash.display.DisplayObject;
    import flash.events.Event;

    import mx.events.FlexEvent;

    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    /**
     * Provides some helper methods for tests.
     */
    public class TestBase
    {

        //------------------------------

        /**
         * Declares a set of expectations.
         *
         * Example:
         *
         *    declare(
         *        expectingEvent(...),
         *        expectingSomethingElse()
         *    )
         */
        protected function declare(... expectations)
        {
            for( var i : int = 0; i < expectations.length; i++ )
            {
                var chainable : ExpectationChainable = expectations[i];
                chainable.expectation.declare(this);
            }
        }

        //------------------------------

        protected function initializeUI(ui : DisplayObject, afterInitialized : Function = null) : void
        {
            var handler : Function = Async.asyncHandler(this, function(e:Event, _:Object) : void {
                if( afterInitialized )
                    afterInitialized();
            }, AsyncTimeout.UI);

            ui.addEventListener(FlexEvent.CREATION_COMPLETE, handler);

            UIImpersonator.addChild(ui);
        }

        //------------------------------

        protected function cleanUpUI() : void
        {
            UIImpersonator.removeAllChildren();
        }

        //------------------------------

        protected function expectingToBeCalled(func : Function = null, timeout : Number = Number.NaN) : Function
        {
            var handler : Function = Async.asyncHandler(this, function (e : Event, o : *) : void
            {
            }, timeout || AsyncTimeout.NONE)

            return function (... args) : void
            {
                handler(null);
                if (func)
                    func.apply(this, args);
            }
        }
    }
}
