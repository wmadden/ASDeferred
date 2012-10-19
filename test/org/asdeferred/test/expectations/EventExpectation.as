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
package org.asdeferred.test.expectations
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    import org.flexunit.async.Async;
    import org.hamcrest.Matcher;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.not;

    /**
     * Expectation that an object will dispatch an event before some timeout.
     */
    public class EventExpectation implements Expectation
    {

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        private var _negated : Boolean;

        public function get negated() : Boolean
        {
            return _negated;
        }

        public function set negated(value : Boolean) : void
        {
            _negated = value;
        }

        //------------------------------

        public var matcher : Matcher;

        //------------------------------

        public var source : IEventDispatcher;

        //------------------------------

        /**
         * Function of the form:
         *
         *     function( event : Event, passThroughData : Object )
         */
        public var eventHandler : Function;

        //------------------------------

        private var test : Object;

        //------------------------------

        public var timeout : int;

        //------------------------------

        private var timeoutHandler : Function;

        //------------------------------

        private var passThroughData : Object;

        //------------------------------

        private var type : String;

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------------------------------------------

        public function EventExpectation(type : String, timeout : int, passThroughData : Object,
                                         timeoutHandler : Function)
        {
            this.type = type;
            this.timeout = timeout;
            this.passThroughData = passThroughData;
            this.timeoutHandler = timeoutHandler;
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        public function declare(test : Object) : void
        {
            if (negated)
            {
                if (matcher)
                {
                    // If a matcher is provided and the expectation is negated, e.g.
                    //     not(
                    //       expectingEvent('someEvent')
                    //         .from(instance)
                    //         .that(...)
                    //     )
                    // then the test is that either no 'someEvent' events are dispatched or that if they are, they do
                    // not satisfy the that() matcher.
                    //
                    // To do this, create an Async event handler and override its timeout function to _not_ fail the
                    // test, since not dispatching an event is valid behaviour.
                    matcher = org.hamcrest.core.not(matcher);

                    Async.handleEvent(test, source, type, on_source_event, timeout, passThroughData,
                                      function (o : Object) : void
                                      {
                                          if (timeoutHandler)
                                              timeoutHandler(o);
                                      });
                }
                else
                {
                    // If no matcher is provided
                    Async.failOnEvent(test, source, type, timeout, timeoutHandler);
                }
            }
            else
            {
                Async.handleEvent(test, source, type, on_source_event, timeout, passThroughData, timeoutHandler);
            }
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Event Handlers
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        private function on_source_event(event : Event, passThroughData : Object) : void
        {
            if (matcher)
                assertThat(event, matcher);

            if (eventHandler)
                eventHandler(event, passThroughData);
        }
    }
}
