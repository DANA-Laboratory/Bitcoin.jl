"""
    Copyright (C) 2018-2019 Simon Castano

    This file is part of Bitcoin.jl

    Bitcoin.jl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    Bitcoin.jl is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
"""

"""
read_varint reads a variable integer from a stream
"""
 function read_varint(s::Base.GenericIOBuffer{Array{UInt8,1}})
     i = UInt8[]
     readbytes!(s, i, 1)
     if i == [0xfd]
         # 0xfd means the next two bytes are the number
         readbytes!(s, i, 2)
         return reinterpret(Int16, i)[1]
     elseif i == [0xfe]
         # 0xfe means the next four bytes are the number
         readbytes!(s, i, 4)
         return reinterpret(Int32, i)[1]
     elseif i == [0xff]
         # 0xff means the next eight bytes are the number
         readbytes!(s, i, 8)
         return reinterpret(Int64, i)[1]
     else
         # anything else is just the integer
         return reinterpret(Int8, i)[1]
     end
 end

"""
Encodes an integer as a varint
"""
 function encode_varint(n::Integer)
    if n < 0xfd
        return [UInt8(n)]
    elseif n < 0x10000
        return prepend!(int2bytes(n, 2), [0xfd])
    elseif n < 0x100000000
        return prepend!(int2bytes(n, 4), [0xfd])
    elseif n < 0x10000000000000000
        return prepend!(int2bytes(n, 8), [0xfd])
    else
        error("Integer, ", i, " is too large")
    end
 end

import ECC.int2bytes

 """
Convert Integer to Array{UInt8}

int2bytes(x::Integer) -> Array{UInt8,1}
"""
function int2bytes(x::Integer, l::Integer=0)
    result = reinterpret(UInt8, [hton(x)])
    i = findfirst(x -> x != 0x00, result)
    if l != 0
        i = length(result) - l + 1
    end
    return result[i:end]
end