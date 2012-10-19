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
package au.com.promedicus.async
{
    import au.com.promedicus.util.lang.splat;

    import flash.events.Event;

    public class PromiseEvent extends Event
{
    public static const RESOLVED : String = "resolved";
    public static const REJECTED : String = "rejected";
    public static const PROGRESS : String = "progress";

    //--------------------------------------------------------------------------------------------------------------
    //  
    //  Properties
    //  
    //--------------------------------------------------------------------------------------------------------------

    //------------------------------
    //  args
    //------------------------------

    private var _args : Array;

    public function get args() : Array
    {
        return _args;
    }

    //--------------------------------------------------------------------------------------------------------------
    //  
    //  Constructor
    //  
    //--------------------------------------------------------------------------------------------------------------

    public function PromiseEvent(args : Array, type : String, bubbles : Boolean = false, cancelable : Boolean = false)
    {
        _args = args;
        super(type, bubbles, cancelable);
    }

    //--------------------------------------------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------------------------------------------

    //------------------------------
    //  [OVERRIDE] clone
    //------------------------------

    public override function clone() : Event
    {
        return new PromiseEvent(args, type, bubbles, cancelable);
    }

    //------------------------------

    /**
     * Call the given function with the arguments that the Promise was rejected or resolved with.
     */
    public function callWithArgs(func : Function) : *
    {
        return splat(func, args);
    }
}
}
