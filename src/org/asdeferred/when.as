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
     * Returns a Promise that succeeds when all given operations succeed, and fails if any of them fail.
     *
     * @param args A variable length list of AsyncOperations, if the first arg is an Array instance, it is considered
     *  to be the collection of AsyncOperations to be considered for resolution/rejection.
     *
     * @return org.asdeferred.Promise
     */
    public function when( ... args ) : Promise
    {
        var result : Deferred = new Deferred();
        
        if( args && args[0] is Array )
        {
            if (args.length != 1)
            {
                throw "If first arg in var args is an Array (expected to be of array of AsyncOperations), not " +
                      "expecting other values in the var arg list!";
            }

            args = args[0];
        }
        
        var ops : Array = args;
        var resolvedOps : Array = [];

        var rejectedHandler : Function = function (event : PromiseEvent) : void
        {
            result.reject();
        };
        var resolvedHandler : Function = function (event : PromiseEvent) : void
        {
            var deferred : Promise = Promise(event.target);

            resolvedOps.push(deferred);

            if( resolvedOps.length == ops.length )
                result.resolve();
        };

        for( var i : Number = 0; i < ops.length; i++ )
        {
            var deferred : Deferred = ops[i] as Deferred;
            deferred.done(resolvedHandler)
                .fail(rejectedHandler);
        }

        return result;
    }
}
