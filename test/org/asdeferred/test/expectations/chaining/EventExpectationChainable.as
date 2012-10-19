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
package org.asdeferred.test.expectations.chaining
{
    import org.asdeferred.test.expectations.EventExpectation;
    import org.asdeferred.test.expectations.Expectation;

    import flash.events.IEventDispatcher;

    import org.hamcrest.Matcher;

    /**
     * Object used to chain methods onto an EventExpectation.
     */
    public class EventExpectationChainable implements ExpectationChainable
    {
        //--------------------------------------------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        private var eventExpectation : EventExpectation;

        //------------------------------

        public function get expectation() : Expectation
        {
            return eventExpectation;
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------------------------------------------

        public function EventExpectationChainable(expectation : EventExpectation)
        {
            eventExpectation = expectation;
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        public function from(source : IEventDispatcher) : EventExpectationChainable
        {
            eventExpectation.source = source;
            return this;
        }

        //------------------------------

        public function that(matcher : Matcher) : EventExpectationChainable
        {
            eventExpectation.matcher = matcher;
            return this;
        }

        //------------------------------

        public function handledBy(eventHandler : Function) : EventExpectationChainable
        {
            eventExpectation.eventHandler = eventHandler;
            return this;
        }

        //------------------------------

        public function within(milliseconds : Number) : EventExpectationChainable
        {
            eventExpectation.timeout = milliseconds;
            return this;
        }

    }
}
