// Copyright (c) 2009-2012 The Bitcoin developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <boost/assign/list_of.hpp> // for 'map_list_of()'
#include <boost/foreach.hpp>

#include "checkpoints.h"

#include "txdb.h"
#include "main.h"
#include "uint256.h"


static const int nCheckpointSpan = 500;

namespace Checkpoints
{
    typedef std::map<int, uint256> MapCheckpoints;

    //
    // What makes a good checkpoint block?
    // + Is surrounded by blocks with reasonable timestamps
    //   (no blocks before with a timestamp after, none after with
    //    timestamp before)
    // + Contains no strange transactions
    //
    static MapCheckpoints mapCheckpoints =
        boost::assign::map_list_of
        (  0,     uint256("0x00000347c656a618f9bfef80a14fa66cf26e34ed4caeba0e3f072eb8b9408ee6") )
        (  2,     uint256("0xf9364e84a73f90efd930971793827c47bff0f695af13c6e8e7a11de7584e0b8a") ) // Premine
        (  10,    uint256("0x72d855332d090a51371e45f19ae7b766abbe56a9589bcf287ca5aed5d20985c9") )
        (  50,    uint256("0xe2322556f4d5a05f2bb4497c5a9647bcf14d8463fd27ac299592428be4336914") )
        (  100,   uint256("0x566e196f627670a230cfc3e2c4ecdc12f92e53e81d32b0eb3ec5d2df4156eece") )
        (  500,   uint256("0x09920e672b839b9c20eb08136a47c1d35ffdc645e8b66258d4f19fc5ea6546e8") )
        (  1000,  uint256("0xf27293554eb63269388c8833c86ac31adb18b4b3ad3f31bb15090914461ff988") )
        (  2000,  uint256("0xafb6da8a473b613a737862e2f16f11baf53006693d1dce44ab00c599893f195f") ) // v1.0.0.1
        (  5000,  uint256("0x10755a3fc2da7f4c228528dea676de17a6aa89d03cf108f9d823c5419a2201e1") )
        (  10500, uint256("0x59001bcb08767fa93cc0ad20b84da1fc0843fd1d8d8c7bc6c196c6cc49236c15") ) // v1.0.0.2
        (  13000, uint256("0x6b15c3ce6cb6af2a4b93a74ebb63fa3e2487dad9913ea513159ba9ff019b84d4") )
        (  16000, uint256("0x754370ee32607b3037d7e402b6e47df06fadc4664afa8d6e2575df3bc7271d8c") )
        (  19000, uint256("0x3df9f229ff5092077859b4cf67451dfccc8cec4b828f388a71ecce43329225f5") ) // v1.0.0.3
        (  25000, uint256("0xc6fc0ed3359d51f215d6facb6e0e61093633d607f27332a9cf8c2ade665f61e9") )
        (  30000, uint256("0x30d549c4fd940efd3abe88b4366527bc53fdba9197ede8a3d4a537e612e4311e") )
        (  35000, uint256("0x7e530128063b4e8e4691e3de08fc68f3f98278a25c8b31f52dd3257fbd352ffd") )
        (  39000, uint256("0x8ec08b1c01c5c885d2272a6ab8dd887f2d440b309929947ac59cbd500e6663c7") ) // v1.0.0.4
    ;

    // TestNet has no checkpoints
    static MapCheckpoints mapCheckpointsTestnet;

    bool CheckHardened(int nHeight, const uint256& hash)
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        MapCheckpoints::const_iterator i = checkpoints.find(nHeight);
        if (i == checkpoints.end()) return true;
        return hash == i->second;
    }

    int GetTotalBlocksEstimate()
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        if (checkpoints.empty())
            return 0;
        return checkpoints.rbegin()->first;
    }

    CBlockIndex* GetLastCheckpoint(const std::map<uint256, CBlockIndex*>& mapBlockIndex)
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        BOOST_REVERSE_FOREACH(const MapCheckpoints::value_type& i, checkpoints)
        {
            const uint256& hash = i.second;
            std::map<uint256, CBlockIndex*>::const_iterator t = mapBlockIndex.find(hash);
            if (t != mapBlockIndex.end())
                return t->second;
        }
        return NULL;
    }

    // Automatically select a suitable sync-checkpoint 
    const CBlockIndex* AutoSelectSyncCheckpoint()
    {
        const CBlockIndex *pindex = pindexBest;
        // Search backward for a block within max span and maturity window
        while (pindex->pprev && pindex->nHeight + nCheckpointSpan > pindexBest->nHeight)
            pindex = pindex->pprev;
        return pindex;
    }

    // Check against synchronized checkpoint
    bool CheckSync(int nHeight)
    {
        const CBlockIndex* pindexSync = AutoSelectSyncCheckpoint();

        if (nHeight <= pindexSync->nHeight)
            return false;
        return true;
    }
}
