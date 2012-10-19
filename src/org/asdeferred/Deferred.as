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
    import org.asdeferred.util.lang.splat;

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
     * Based on the jQuery Deferred object, which in turn is based on the CommonJS Promise object.
     *
     * A Deferred object is used to enqueue behaviour in response to the completion of an asynchronous process. It
     * provides an easy way to chain callbacks onto an open-ended process without the implementor being aware of them.
     *
     * For example, if you wanted to open an editor to edit a model you could do something like this:
     *
     *   openEditor() // Returns Deferred
     *      .done(function() {
     *          model.save();
     *      })
     *      .fail(function() {
     *          model.reset();
     *      })
     */
    public class Deferred extends EventDispatcher implements Promise
    {
        public static const RESOLVED : String = "resolved";
        public static const REJECTED : String = "rejected";
        public static const PENDING : String = "pending";

        public static const ALREADY_RESOLVED : Promise = new Deferred().resolve();
        public static const ALREADY_REJECTED : Promise = new Deferred().reject();

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        private var _state : String = PENDING;

        public function get state() : String
        {
            return _state;
        }

        //------------------------------

        public function get isPending() : Boolean
        {
            return state == PENDING;
        }

        //------------------------------

        public function get isResolved() : Boolean
        {
            return state == RESOLVED;
        }

        //------------------------------

        public function get isRejected() : Boolean
        {
            return state == REJECTED;
        }

        //------------------------------

        public function get promise() : Promise
        {
            return this;
        }

        //------------------------------

        private var eventListeners : Object = {};

        //------------------------------

        private var args : Array;

        //------------------------------

        private var timeoutTimer : Timer;

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Promise/Promise Methods
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------
        //  resolve
        //------------------------------

        public function resolve(... args) : Promise
        {
            if( state != PENDING )
                return this;

            _state = RESOLVED;
            this.args = args;

            dispatchEvent(new PromiseEvent(args, PromiseEvent.RESOLVED));

            removeAllEventListeners();
            return this;
        }

        //------------------------------
        //  done
        //------------------------------

        public function done(eventHandler : Function) : Promise
        {
            if( state == RESOLVED )
            {
                super.addEventListener(PromiseEvent.RESOLVED, eventHandler);
                dispatchEvent(new PromiseEvent(this.args, PromiseEvent.RESOLVED));
                removeEventListener(PromiseEvent.RESOLVED, eventHandler)
            }
            else if( state == PENDING )
                addEventListener(PromiseEvent.RESOLVED, eventHandler);

            return this;
        }

        //------------------------------
        //  reject
        //------------------------------

        public function reject(... args) : Promise
        {
            if( state != PENDING )
                return this;

            _state = REJECTED;
            this.args = args;

            dispatchEvent(new PromiseEvent(args, PromiseEvent.REJECTED));

            removeAllEventListeners();
            return this;
        }

        //------------------------------
        //  fail
        //------------------------------

        public function fail(eventHandler : Function) : Promise
        {
            if( state == REJECTED )
            {
                // TODO: execute handler with arguments passed to reject
                super.addEventListener(PromiseEvent.REJECTED, eventHandler);
                dispatchEvent(new PromiseEvent(args, PromiseEvent.REJECTED));
                removeEventListener(PromiseEvent.REJECTED, eventHandler);
            }
            else if( state == PENDING )
                addEventListener(PromiseEvent.REJECTED, eventHandler);

            return this;
        }

        //------------------------------
        //  notify
        //------------------------------

        public function notify(... args) : Promise
        {
            if( state != PENDING )
                return this;

            dispatchEvent(new PromiseEvent(args, PromiseEvent.PROGRESS));
            return this;
        }

        //------------------------------
        //  progress
        //------------------------------

        public function progress(eventHandler : Function) : Promise
        {
            addEventListener(PromiseEvent.PROGRESS, eventHandler);
            return this;
        }

        //------------------------------
        //  then
        //------------------------------

        public function then(eventHandler : Function) : Promise
        {
            done(eventHandler);
            fail(eventHandler);
            return this;
        }

        //------------------------------

        public function decidedBy(operation : Promise) : Promise
        {
            operation
                .done(function (event : PromiseEvent) : void
                      {
                          resolve.apply(this, event.args);
                      })
                .fail(function (event : PromiseEvent) : void
                      {
                          reject.apply(this, event.args);
                      });

            return this;
        }

        //------------------------------

        public function timeoutAfter(ms : int) : void
        {
            if (!isPending)
                return;

            if (timeoutTimer)
                throw new Error("Deferred has already been set to time out after " + timeoutTimer.delay + "ms");

            timeoutTimer = new Timer(ms, 1);
            timeoutTimer.addEventListener(TimerEvent.TIMER, on_timer_tick);
            timeoutTimer.start();
        }

        //------------------------------

        public function chain(... operations) : Promise
        {
            var deferred : Deferred = new Deferred();

            fail(function (event : PromiseEvent) : void
                 {
                     event.callWithArgs(deferred.reject);
                 });

            done(function (event : PromiseEvent) : void
                {
                    if (operations.length == 0)
                    {
                        event.callWithArgs(deferred.resolve);
                        return;
                    }

                    var nextOperation : Function = operations.shift();
                    var nextOperationPromise : Promise = event.callWithArgs(nextOperation)

                    if (!nextOperationPromise)
                        throw new Error("Chained operation must return a Promise");

                    deferred.decidedBy(
                        splat(nextOperationPromise.chain, operations)
                    );
                });

            return deferred;
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        public override function addEventListener(type : String, listener : Function, useCapture : Boolean = false,
                                                  priority : int = 0, useWeakReference : Boolean = false) : void
        {
            if( state != PENDING )
                return;

            super.addEventListener(type, listener, useCapture, priority, useWeakReference);

            if( !eventListeners[type] )
                eventListeners[type] = [];

            eventListeners[type].push({ listener: listener, useCapture: useCapture });
        }

        //------------------------------

        private function removeAllEventListeners() : void
        {
            for( var event : String in eventListeners )
            {
                var listeners : Array = eventListeners[event];
                for( var i : Number = 0; i < listeners.length; i++ )
                    removeEventListener(event, listeners[i]['listener'], listeners[i]['useCapture']);
            }

            if( timeoutTimer )
                cleanUpTimer();
        }

        //------------------------------

        private function cleanUpTimer() : void
        {
            timeoutTimer.stop();
            timeoutTimer.removeEventListener(TimerEvent.TIMER, on_timer_tick);
        }

        //--------------------------------------------------------------------------------------------------------------
        //
        //  Event Handlers
        //
        //--------------------------------------------------------------------------------------------------------------

        //------------------------------

        private function on_timer_tick(event : TimerEvent) : void
        {
            reject();
        }

    }
}
