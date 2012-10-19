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
    /**
     * Calls the given function with the arguments in the given array, similar to Function::apply(). In contrast to
     * apply(), splat() will preserve the `this' value of the function, if any.
     *
     * The arguments array cannot be longer than 5 elements.
     *
     * @param target The function to be called
     * @param args The arguments args to call it with
     * @return The return value of the function, if any
     */
    public function splat(target : Function, args : Array) : *
    {
        switch( args.length )
        {
            case 0:
                return target();
            case 1:
                return target(args[0]);
            case 2:
                return target(args[0], args[1]);
            case 3:
                return target(args[0], args[1], args[2]);
            case 4:
                return target(args[0], args[1], args[2], args[3]);
            case 5:
                return target(args[0], args[1], args[2], args[3], args[4]);
        }
    }
}
