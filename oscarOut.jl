using DelimitedFiles
function nrows(A::Matrix{BigInt})
  return size(A, 1)
end

function ncols(A::Matrix{BigInt})
   return size(A, 2)
end

function hnf_with_transform(A)
  return hnf_kb_with_transform(A)
end

function hnf_kb_with_transform(A::Matrix{BigInt})
   return _hnf_kb(A, Val(true))
end

function _hnf_kb(A, ::Val{with_transform} = Val(false)) where {with_transform}
   H = deepcopy(A)
   m = nrows(H)
   if with_transform
      U =  Matrix{BigInt}(I, m, m)
      hnf_kb!(H, U, true)
      return H, U
   else
      U = Matrix{BigInt}(undef, 0, 0)
      hnf_kb!(H, U, false)
      return H
   end
end

function hnf_kb!(H, U, with_trafo::Bool = false, start_element::Int = 1)
   m = nrows(H)
   n = ncols(H)
   pivot = zeros(Int, n) # pivot[j] == i if the pivot of column j is in row i

   # Find the first non-zero entry of H
   row1, col1 = kb_search_first_pivot(H, start_element)
   if row1 == 0
      return nothing
   end
   pivot[col1] = row1
   kb_canonical_row!(H, U, row1, col1, with_trafo)
   pivot_max = col1
   t = 0
   t1 = 0
   t2 = 0
   a = 0
   b = 0
   for i = row1 + 1:m
      new_pivot = false
      for j = start_element:n
         if H[i, j] == 0
            continue
         end
         if pivot[j] == 0
            # We found a non-zero entry in a column without a pivot: This is a
            # new identity_matrix
            pivot[j] = i
            pivot_max = max(pivot_max, j)
            new_pivot = true
         else
            # We have a pivot for this column: Use it to write 0 in H[i, j]
            p = pivot[j]
            d, u, v = gcdx(H[p, j], H[i, j])
            a = H[p, j] / d
            b = -H[i, j] / d
            for c = j:n
               t = deepcopy(H[i, c])
               #mul!(t1, a, H[i,c])
               t1 = a * H[i, c]
               #mul!(t2, b, H[p, c])
               t2 = b * H[p, c]
               H[i, c] = t1 + t2
               #mul!(t1, u, H[p, c])
               t1 = u * H[p,c]
               #mul!(t2, v, t)
               t2 = v * t
               H[p, c] = t1 + t2
            end
            if with_trafo
               for c = 1:m
                  t = deepcopy(U[i, c])
                  #mul!(t1, a, U[i, c])
                  t1 = a * U[i, c]
                  #mul!(t2, b, U[p, c])
                  t2 = b * U[p, c]
                  U[i, c] = t1 + t2
                  #mul!(t1, u, U[p, c])
                  t1 = u * U[p, c]
                  #mul!(t2, v, t)
                  t2 = v * t
                  U[p, c] = t1 + t2
               end
            end
         end
         # We changed the pivot of column j (or found a new one).
         # We have do reduce the entries marked with # in
         # ( 0 0 0 . * )
         # ( . # # * * )
         # ( 0 0 . * * )
         # ( 0 . # * * )
         # ( * * * * * )
         # where . are pivots and i = 4, j = 2. (This example is for the
         # "new pivot" case.)
         kb_canonical_row!(H, U, pivot[j], j, with_trafo)
         for c = j:pivot_max
            if pivot[c] == 0
               continue
            end
            kb_reduce_column!(H, U, pivot, c, with_trafo)
         end
         if new_pivot
            break
         end
      end
   end
   kb_sort_rows!(H, U, pivot, with_trafo, start_element)
   return nothing
end

# Reduces the entries above H[pivot[c], c]
function kb_reduce_column!(H::Matrix{BigInt}, U::Matrix{BigInt}, pivot::Vector{Int}, c::Int, with_trafo::Bool, start_element::Int = 1)

   # Let c = 4 and pivot[c] = 4. H could look like this:
   # ( 0 . * # * )
   # ( . * * # * )
   # ( 0 0 0 0 . )
   # ( 0 0 0 . * )
   # ( * * * * * )
   #
   # (. are pivots, we want to reduce the entries marked with #)
   # The #'s are in rows whose pivot is in a column left of column c.

   r = pivot[c]
   t = 0
   for i = start_element:c - 1
      p = pivot[i]
      if p == 0
         continue
      end
      # So, the pivot in row p is in a column left of c.
      if H[p, c] == 0
         continue
      end
      #ldiv!(q, -H[p, c], H[r, c])
      q = floor(-H[p,c] / H[r,c])
      for j = c:ncols(H)
         #mul!(t, q, H[r, j])
         t = q * H[r, j]
         H[p, j] += t
      end
      if with_trafo
         for j = 1:ncols(U)
            #mul!(t, q, U[r, j])
            t = q * U[r, j]
            U[p, j] += t
         end
      end
   end
   return nothing
end

canonical_unit(a::BigInt) = if a >= 0 return BigInt(1) else return BigInt(-1) end

function kb_search_first_pivot(H, start_element::Int = 1)
   for r = start_element:nrows(H)
      for c = start_element:ncols(H)
         if !(H[r, c] == 0)
            return r, c
         end
      end
   end
   return 0, 0
end

function kb_canonical_row!(H, U, r::Int, c::Int, with_trafo::Bool)
   cu = canonical_unit(H[r, c])
   if cu != 1
      for j = c:ncols(H)
         H[r, j] = H[r, j] / cu
      end
      if with_trafo
         for j = 1:ncols(U)
            U[r, j] = U[r, j] / cu
         end
      end
   end
   return nothing
end

function kb_sort_rows!(H::Matrix{BigInt}, U::Matrix{BigInt}, pivot::Vector{Int}, with_trafo::Bool, start_element::Int = 1)
   m = nrows(H)
   n = ncols(H)
   pivot2 = zeros(Int, m)
   for i = 1:n
      if pivot[i] == 0
         continue
      end
      pivot2[pivot[i]] = i
   end

   r1 = start_element
   for i = start_element:n
      r2 = pivot[i]
      if r2 == 0
         continue
      end
      if r1 != r2
         swap_rows!(H, r1, r2)
         with_trafo ? swap_rows!(U, r1, r2) : nothing
         p = pivot2[r1]
         pivot[i] = r1
         if p != 0
            pivot[p] = r2
         end
         pivot2[r1] = i
         pivot2[r2] = p
      end
      r1 += 1
      if r1 == m
         break
      end
   end
   return nothing
end

function swap_rows!(a::Matrix{BigInt}, i::Int, j::Int)
   (1 <= i <= nrows(a) && 1 <= j <= nrows(a)) || throw(BoundsError())
   if i != j
      for k = 1:ncols(a)
         x = a[i, k]
         a[i, k] = a[j, k]
         a[j, k] = x
      end
   end
   return a
end
