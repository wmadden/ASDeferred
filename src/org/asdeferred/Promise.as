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

    /**
     * See jQuery Promise; CommonJS Promises/A.
     *
     * A Promise represents the eventual value returned from the single completion of an operation.
     */
    public interface Promise
    {

        //------------------------------

        /**
         * True if the promise has not yet been resolved or rejected.
         */
        function get isPending() : Boolean;

        //------------------------------

        /**
         * True if the promise has already been resolved.
         */
        function get isResolved() : Boolean;

        //------------------------------

        /**
         * True if the promise has already been rejected.
         */
        function get isRejected() : Boolean;

        //------------------------------

        /**
         * Adds a listener for when the promise has been fulfilled.
         * @param Function A function that will be invoked with the same arguments that resolve() was passed.
         * @return Promise Self
         */
        function done(callback : Function) : Promise;

        //------------------------------

        /**
         * Adds a listener for when the promise has failed to be fulfilled.
         * @param Function A function that will be invoked with the same arguments that reject() was passed.
         * @return Promise Self
         */
        function fail(callback : Function) : Promise;

        //------------------------------

        /**
         * Adds a listener for when the promise makes progress.
         *
         * @param Function A function that will be invoked with the same arguments that notify() was passed.
         *
         * @return Promise Self
         */
        function progress(callback : Function) : Promise;

        //------------------------------

        /**
         * Registers a callback function to be executed when the promise is resolved or rejected, regardless of its
         * outcome.
         *
         * N.B. This implementation of then() diverges from jQuery's.
         *
         * @param Function A function that will be invoked with the same arguments that resolve() or reject() was
         *                 passed.
         * @return Promise Self
         */
        function then(callback : Function) : Promise;

        //------------------------------

        /**
         * Chains a set of asynchronous operations onto this one. Each operation is executed only if the preceding one
         * succeeds, and the whole chain fails if any operation fails.
         *
         * This is useful for scenarios when you have different branches of operations that must execute depending on
         * the success or failure of other operations.
         *
         * For example:
         *
         *      function loadOrder(url) : Promise
         *      {
         *          // Order is only loaded once its patient and the patient's referral are also loaded (for example)
         *          return remote.getModel(url)
         *              .chain(
         *                  // First chained operation, called when the remote call succeeds
         *                  function(order : Order) : Promise {
         *                      this.order = order;
         *                      return order.loadPatient();
         *                  },
         *
         *                  // Second chained operation, called when the patient has loaded
         *                  function() : Promise {
         *                      var deferred : Deferred = new Deferred();
         *
         *                      order.patient.loadReferral()
         *                          .done(deferred.resolve)
         *                          .fail(function() : void
         *                                {
         *                                    logger.error("Failed to load the patient! Oh no!");
         *                                    // If we can recover...
         *                                    deferred.decidedBy(order.patient.tryToLoadReferralAgain());
         *                                });
         *
         *                      return deferred;
         *                  },
         *
         *                  // Third chained operation, called if the second succeeded or recovered from its own failure
         *                  function() : Promise {
         *                      doSomethingElse();
         *                      return new Deferred().resolve();
         *                  }
         *              );
         *      }
         *
         * The operations in the chain are functions which will be invoked with the same arguments that the preceding
         * promise was resolved with, for convenience. They must return a Promise that they will complete.
         *
         * chain() returns a Promise itself, indicating the success or failure of the chain as a whole. In this way
         * chains may be composed of other chains. Logical branching can be achieved by adding error handlers in the
         * operations themselves, as in the second operation in the example.
         *
         * @return Promise
         */
        function chain(... operations) : Promise;

    }
}
