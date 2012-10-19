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
    import org.asdeferred.test.expectations.chaining.EventExpectationChainable;

    //------------------------------

    /**
     * Requires [Async] metadata tag. Has no effect unless from() is called on the return value.
     *
     * Example:
     *
     *     [Test]
     *     public function itShouldDispatchSomeEvent() : void
     *     {
     *         expectEvent("someEvent")
     *            .from(instance)
     *            .that(hasPropertyWithValue('message', 'Some interesting value'));
     *     }
     *
     * @param type The type identifier of the event to expect
     * @return A chainable object
     */
    public function expectingEvent(type : String, timeout : int = 500, passThroughData : Object = null,
                         timeoutHandler : Function = null) : EventExpectationChainable
    {
        return new EventExpectationChainable(new EventExpectation(type, timeout, passThroughData, timeoutHandler));
    }
}
