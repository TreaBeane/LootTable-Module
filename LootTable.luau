--!strict
--[[
    Disclaimer of Warranty:
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
    DEALINGS IN THE SOFTWARE.

    Limitation of Liability:
    IN NO EVENT SHALL THE CREATOR, AUTHORS, OR COPYRIGHT HOLDERS OF THIS LUA 
    SCRIPT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
    THE POSSIBILITY OF SUCH DAMAGE.
]]
-- Header
local LootTable = {
	u = 0
}

-- Definitions
export type LootTable = {
	Entries: { LootTableEntry }
}

export type LootTableEntry = {
	Value: any,
	Weight: number,
	Quality: (number|nil),
	AdjustedWeight: (number|nil)
}

-- Functions
local function _random(x: number?, y: number?)
	LootTable.u = LootTable.u + 1
	if x ~= nil and y ~= nil then
		return math.floor(x + (math.random(math.randomseed(os.time() + LootTable.u)) * 999999 % y))
	else
		return math.floor((math.random(math.randomseed(os.time() + LootTable.u)) * 100))
	end
end

function LootTable.NormalizedTableEntries(lootTable: LootTable, luck: (number|nil), luckScaleFactor: number?): { LootTableEntry }
	local normalizedSum = 0
	local normalizedTable = {}
	
	for _, entry in ipairs(lootTable.Entries) do
		local adjustedWeight = math.floor((entry.Weight * 100_000) + ((entry.Quality or 0) * (luckScaleFactor or 500) * (luck or 0)))
		normalizedSum += adjustedWeight
		
		local normalizedEntry = table.clone(entry)
		normalizedEntry.AdjustedWeight = adjustedWeight
		table.insert(normalizedTable, normalizedEntry)
	end
	
	for _, entry in ipairs(normalizedTable) do
		local adjustedWeight = entry.AdjustedWeight
		if adjustedWeight then
			entry.Weight = adjustedWeight / normalizedSum
		end
		entry.AdjustedWeight = nil
	end
	
	return normalizedTable
end

function LootTable.Roll(lootTable: LootTable, rolls: (number|nil), luck: (number|nil)): { LootTableEntry }
	local rewards = {}
	local normalized = LootTable.NormalizedTableEntries(lootTable, luck or 1)
	
	for i = 1, (rolls or 1) do
		local p = _random(0, 999999) / 999999
		local runningTotal = 0

		for _, entry in ipairs(normalized) do
			runningTotal += entry.Weight
			if (p < runningTotal) then
				table.insert(rewards, entry)
				break
			end
		end
	end

	return rewards
end

function LootTable.RollWithSeed(seed: number, lootTable: LootTable, rolls: (number|nil), luck: (number|nil)): { LootTableEntry }
	local rewards = {}
	local normalized = LootTable.NormalizedTableEntries(lootTable, luck or 1)
	for i = 1, (rolls or 1) do
		math.randomseed(seed)
		local p = math.random()
		local runningTotal = 0

		for _, entry in ipairs(normalized) do
			runningTotal += entry.Weight
			if (p < runningTotal) then
				table.insert(rewards, entry)
				break
			end
		end
	end
	return rewards
end

return LootTable