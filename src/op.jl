"""
    Copyright (C) 2019 Simon Castano

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

function encode_num(num::Integer)
    if num == 0
        return UInt8[]
    end
    abs_num = abs(num)
    negative = num < 0
    result = UInt8[]
    while abs_num != 0
        push!(result, abs_num & 0xff)
        abs_num >>= 8
    end
    # if the top bit is set,
    # for negative numbers we ensure that the top bit is set
    # for positive numbers we ensure that the top bit is not set
    if result[end] & 0x80 != 0
        if negative
            push!(result, 0x80)
        else
            push!(result, 0x00)
        end
    elseif negative
        result[end] |= 0x80
    end
    return result
end

function decode_num(element::Array{UInt8,1})
    if isempty(element)
        return 0
    end
    if length(element) > div(Sys.WORD_SIZE, 8)
        T = BigInt
    else
        T = Int
    end
    result = 0
    # reverse for big endian
    big_endian = reverse(element)
    # top bit being 1 means it's negative
    if big_endian[1] & 0x80 != 0
        negative = true
        result = T(big_endian[1] & 0x7f)
    else
        negative = false
        result = T(big_endian[1])
    end
    for c in big_endian[2:end]
        result <<= 8
        result += c
    end
    if negative
        return -result
    else
        return result
    end
end

function op_0(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(0))
    return true
end

function op_1negate(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(-1))
    return true
end

function op_1(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(1))
    return true
end

function op_2(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(2))
    return true
end

function op_3(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(3))
    return true
end

function op_4(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(4))
    return true
end

function op_5(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(5))
    return true
end

function op_6(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(6))
    return true
end

function op_7(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(7))
    return true
end

function op_8(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(8))
    return true
end

function op_9(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(9))
    return true
end

function op_10(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(10))
    return true
end

function op_11(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(11))
    return true
end

function op_12(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(12))
    return true
end

function op_13(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(13))
    return true
end

function op_14(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(14))
    return true
end

function op_15(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(15))
    return true
end

function op_16(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(16))
    return true
end

function op_nop(stack::Array{Array{UInt8,1},1})
    return true
end

# TODO verify actual behavior
function op_if(stack::Array{Array{UInt8,1},1}, items::Array{UInt8,1})
    if length(stack) < 1
        return false
    end
    # go through and re-make the items array based on the top stack element
    true_items = UInt8[]
    false_items = UInt8[]
    current_array = true_items
    found = false
    num_endifs_needed = 1
    while length(items) > 0
        item = popfirst!(items)
        if item in [99, 100]
            # nested if, we have to go another endif
            num_endifs_needed += 1
            push!(current_array, item)
        elseif num_endifs_needed == 1 && item == 103
            current_array = false_items
        elseif item == 104
            if num_endifs_needed == 1
                found = true
                break
            else
                num_endifs_needed -= 1
                push!(current_array, item)
            end
        else
            push!(current_array, item)
        end
    end
    if !found
        return false
    end
    element = pop!(stack)
    if decode_num(element) == 0
        prepend!(items, false_items)
    else
        prepend!(items, true_items)
    end
    return true
end

function op_notif(stack::Array{Array{UInt8,1},1}, items::Array{UInt8,1})
    if length(stack) < 1
        return false
    end
    # go through and re-make the items array based on the top stack element
    true_items = UInt8[]
    false_items = UInt8[]
    current_array = true_items
    found = False
    num_endifs_needed = 1
    while length(items) > 0
        item = popfirst!(items)
        if item in [99, 100]
            # nested if, we have to go another endif
            num_endifs_needed += 1
            push!(current_array, item)
        elseif num_endifs_needed == 1 && item == 103
            current_array = false_items
        elseif item == 104
            if num_endifs_needed == 1
                found = true
                break
            else
                num_endifs_needed -= 1
                push!(current_array, item)
            end
        else
            push!(current_array, item)
        end
    end
    if !found
        return false
    end
    element = pop!(stack)
    if decode_num(element) == 0
        prepend!(items, true_items)
    else
        prepend!(items, false_items)
        return true
    end
end

function op_verify(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    element = pop!(stack)
    if decode_num(element) == 0
        return false
    end
    return true
end

function op_return(stack::Array{Array{UInt8,1},1})
    return false
end

function op_toaltstack(stack::Array{Array{UInt8,1},1}, altstack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    push!(altstack, pop!(stack))
    return true
end

function op_fromaltstack(stack::Array{Array{UInt8,1},1}, altstack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    push!(stack, pop!(altstack))
    return true
end

function op_2drop(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    pop!(stack)
    pop!(stack)
    return true
end

function op_2dup(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    append!(stack, stack[end-1:end])
    return true
end

function op_3dup(stack::Array{Array{UInt8,1},1})
    if length(stack) < 3
        return false
    end
    append!(stack, stack[end-2:end])
    return true
end

function op_2over(stack::Array{Array{UInt8,1},1})
    if length(stack) < 4
        return false
    end
    append!(stack, stack[end-3:end-2])
    return true
end

function op_2rot(stack::Array{Array{UInt8,1},1})
    if length(stack) < 6
        return false
    end
    append!(stack, stack[end-5:end-4])
    return true
end

function op_2swap(stack::Array{Array{UInt8,1},1})
    if length(stack) < 4
        return false
    end
    stack[end-3:end] = append!(stack[end-1:end],stack[end-3:end-2])
    return true
end

function op_ifdup(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    if decode_num(stack[end]) != 0
        push!(stack, stack[end])
    end
    return true
end

function op_depth(stack::Array{Array{UInt8,1},1})
    push!(stack, encode_num(length(stack)))
    return true
end

function op_drop(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    pop!(stack)
    return true
end

function op_dup(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    push!(stack, stack[end])
    return true
end

function op_nip(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    splice!(stack,length(stack)-1)
    return true
end

function op_over(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    push!(stack, stack[end-1])
    return true
end

function op_pick(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    n = decode_num(pop!(stack))
    if length(stack) < n
        return false
    end
    push!(stack, stack[end-n+1])
    return true
end

function op_roll(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    n = decode_num(pop!(stack))
    if length(stack) < n
        return false
    end
    if n == 0
        return true
    end
    element = splice!(stack, length(stack)-n+1)
    push!(stack, element)
    return true
end

function op_rot(stack::Array{Array{UInt8,1},1})
    if length(stack) < 3
        return false
    end
    stack[end-2:end] = circshift(stack[end-2:end],-1)
    return true
end

function op_swap(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    element = splice!(stack, length(stack) - 1)
    push!(stack, element)
    return true
end

function op_tuck(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    element = stack[end]
    splice!(stack, length(stack)-1:length(stack)-2, [element])
    return true
end

function op_size(stack::Array{Array{UInt8,1},1})
    if length(stack) < 1
        return false
    end
    push!(stack, encode_num(length(stack[end])))
    return true
end

function op_equal(stack::Array{Array{UInt8,1},1})
    if length(stack) < 2
        return false
    end
    element1 = pop!(stack)
    element2 = pop!(stack)
    if element1 == element2
        push!(stack, encode_num(1))
    else
        push!(stack, encode_num(0))
    end
    return true
end

function op_equalverify(stack::Array{Array{UInt8,1},1})
    return op_equal(stack) && op_verify(stack)
end

# OP_CODE_FUNCTIONS = Dict([
#     (0,  op_0),
#     (79,  op_1negate),
#     (81,  op_1),
#     (82,  op_2),
#     (83,  op_3),
#     (84,  op_4),
#     (85,  op_5),
#     (86,  op_6),
#     (87,  op_7),
#     (88,  op_8),
#     (89,  op_9),
#     (90,  op_10),
#     (91,  op_11),
#     (92,  op_12),
#     (93,  op_13),
#     (94,  op_14),
#     (95,  op_15),
#     (96,  op_16),
#     (97,  op_nop),
#     (99,  op_if),
#     (100,  op_notif),
#     (105,  op_verify),
#     (106,  op_return),
#     (107,  op_toaltstack),
#     (108,  op_fromaltstack),
#     (109,  op_2drop),
#     (110,  op_2dup),
#     (111,  op_3dup),
#     (112,  op_2over),
#     (113,  op_2rot),
#     (114,  op_2swap),
#     (115,  op_ifdup),
#     (116,  op_depth),
#     (117,  op_drop),
#     (118,  op_dup),
#     (119,  op_nip),
#     (120,  op_over),
#     (121,  op_pick),
#     (122,  op_roll),
#     (123,  op_rot),
#     (124,  op_swap),
#     (125,  op_tuck),
#     (130,  op_size),
#     (135,  op_equal),
#     (136,  op_equalverify),
#     (139,  op_1add),
#     (140,  op_1sub),
#     (143,  op_negate),
#     (144,  op_abs),
#     (145,  op_not),
#     (146,  op_0notequal),
#     (147,  op_add),
#     (148,  op_sub),
#     (154,  op_booland),
#     (155,  op_boolor),
#     (156,  op_numequal),
#     (157,  op_numequalverify),
#     (158,  op_numnotequal),
#     (159,  op_lessthan),
#     (160,  op_greaterthan),
#     (161,  op_lessthanorequal),
#     (162,  op_greaterthanorequal),
#     (163,  op_min),
#     (164,  op_max),
#     (165,  op_within),
#     (166,  op_ripemd160),
#     (167,  op_sha1),
#     (168,  op_sha256),
#     (169,  op_hash160),
#     (170,  op_hash256),
#     (172,  op_checksig),
#     (173,  op_checksigverify),
#     (174,  op_checkmultisig),
#     (175,  op_checkmultisigverify),
#     (176,  op_nop),
#     (177,  op_checklocktimeverify),
#     (178,  op_checksequenceverify),
#     (179,  op_nop),
#     (180,  op_nop),
#     (181,  op_nop),
#     (182,  op_nop),
#     (183,  op_nop),
#     (184,  op_nop),
#     (185,  op_nop)])
#
# OP_CODE_NAMES = Dict([
#     (0, "OP_0"),
#     (76, "OP_PUSHDATA1"),
#     (77, "OP_PUSHDATA2"),
#     (78, "OP_PUSHDATA4"),
#     (79, "OP_1NEGATE"),
#     (81, "OP_1"),
#     (82, "OP_2"),
#     (83, "OP_3"),
#     (84, "OP_4"),
#     (85, "OP_5"),
#     (86, "OP_6"),
#     (87, "OP_7"),
#     (88, "OP_8"),
#     (89, "OP_9"),
#     (90, "OP_10"),
#     (91, "OP_11"),
#     (92, "OP_12"),
#     (93, "OP_13"),
#     (94, "OP_14"),
#     (95, "OP_15"),
#     (96, "OP_16"),
#     (97, "OP_NOP"),
#     (99, "OP_IF"),
#     (100, "OP_NOTIF"),
#     (103, "OP_ELSE"),
#     (104, "OP_ENDIF"),
#     (105, "OP_VERIFY"),
#     (106, "OP_RETURN"),
#     (107, "OP_TOALTSTACK"),
#     (108, "OP_FROMALTSTACK"),
#     (109, "OP_2DROP"),
#     (110, "OP_2DUP"),
#     (111, "OP_3DUP"),
#     (112, "OP_2OVER"),
#     (113, "OP_2ROT"),
#     (114, "OP_2SWAP"),
#     (115, "OP_IFDUP"),
#     (116, "OP_DEPTH"),
#     (117, "OP_DROP"),
#     (118, "OP_DUP"),
#     (119, "OP_NIP"),
#     (120, "OP_OVER"),
#     (121, "OP_PICK"),
#     (122, "OP_ROLL"),
#     (123, "OP_ROT"),
#     (124, "OP_SWAP"),
#     (125, "OP_TUCK"),
#     (130, "OP_SIZE"),
#     (135, "OP_EQUAL"),
#     (136, "OP_EQUALVERIFY"),
#     (139, "OP_1ADD"),
#     (140, "OP_1SUB"),
#     (143, "OP_NEGATE"),
#     (144, "OP_ABS"),
#     (145, "OP_NOT"),
#     (146, "OP_0NOTEQUAL"),
#     (147, "OP_ADD"),
#     (148, "OP_SUB"),
#     (154, "OP_BOOLAND"),
#     (155, "OP_BOOLOR"),
#     (156, "OP_NUMEQUAL"),
#     (157, "OP_NUMEQUALVERIFY"),
#     (158, "OP_NUMNOTEQUAL"),
#     (159, "OP_LESSTHAN"),
#     (160, "OP_GREATERTHAN"),
#     (161, "OP_LESSTHANOREQUAL"),
#     (162, "OP_GREATERTHANOREQUAL"),
#     (163, "OP_MIN"),
#     (164, "OP_MAX"),
#     (165, "OP_WITHIN"),
#     (166, "OP_RIPEMD160"),
#     (167, "OP_SHA1"),
#     (168, "OP_SHA256"),
#     (169, "OP_HASH160"),
#     (170, "OP_HASH256"),
#     (171, "OP_CODESEPARATOR"),
#     (172, "OP_CHECKSIG"),
#     (173, "OP_CHECKSIGVERIFY"),
#     (174, "OP_CHECKMULTISIG"),
#     (175, "OP_CHECKMULTISIGVERIFY"),
#     (176, "OP_NOP1"),
#     (177, "OP_CHECKLOCKTIMEVERIFY"),
#     (178, "OP_CHECKSEQUENCEVERIFY"),
#     (179, "OP_NOP4"),
#     (180, "OP_NOP5"),
#     (181, "OP_NOP6"),
#     (182, "OP_NOP7"),
#     (183, "OP_NOP8"),
#     (184, "OP_NOP9"),
#     (185, "OP_NOP10")])
