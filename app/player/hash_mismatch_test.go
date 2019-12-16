package player

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMismatch(t *testing.T) {
	hash := "3b19767c1059ce3afc8ff30d608a219dce779997092164baa7f144773485e2210947b70685af587b7870044b5952c7d2"
	bStore := GetBlobStore()
	_, err := bStore.Get(hash)
	require.Nil(t, err)
}
