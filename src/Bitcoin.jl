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

module Bitcoin

using ECC
using SHA: sha1, sha256
using Ripemd: ripemd160
using Base58: base58checkencode
export Tx, TxIn, TxOut, Script
export address, wif, txparse, txserialize, txid, txfee, txsighash, scriptevaluate, txfetch

const SIGHASH_ALL = 1
const SIGHASH_NONE = 2
const SIGHASH_SINGLE = 3

include("helper.jl")
include("address.jl")
include("op.jl")
include("script.jl")
include("tx.jl")

end # module
