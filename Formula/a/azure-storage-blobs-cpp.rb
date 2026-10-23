class AzureStorageBlobsCpp < Formula
  desc "Microsoft Azure Storage Blobs SDK for C++"
  homepage "https://github.com/Azure/azure-sdk-for-cpp/tree/main/sdk/storage/azure-storage-blobs"
  url "https://github.com/Azure/azure-sdk-for-cpp/archive/refs/tags/azure-storage-blobs_12.19.1.tar.gz"
  sha256 "2f7af311f5c21b3eaf797d3184b50ac741652e534b3b3d0346a4bb88427c6d06"
  license "MIT"

  livecheck do
    url :stable
    regex(/^azure-storage-blobs[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "d00a0173834ed47f6469ace6ea8c31edc01f116fcad5ad7b9c204f639c07d232"
  end

  depends_on "cmake" => :build
  depends_on "azure-core-cpp"
  depends_on "azure-storage-common-cpp"
  depends_on "flatcc"
  depends_on "nanoarrow"

  deny_network_access!

  def install
    ENV["AZURE_SDK_DISABLE_AUTO_VCPKG"] = "1"
    # TODO: Remove when upstream supports shared flatcc: https://github.com/Azure/azure-sdk-for-cpp/issues/7437
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DFLATCCRT_LIB_PATH_RELEASE=#{formula_opt_lib("flatcc")/shared_library("libflatccrt")}
    ]
    system "cmake", "-S", "sdk/storage/azure-storage-blobs", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # From https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/storage/azure-storage-blobs/test/ut/simplified_header_test.cpp
    (testpath/"test.cpp").write <<~CPP
      #include <azure/storage/blobs.hpp>

      int main() {
        Azure::Storage::Blobs::BlobServiceClient serviceClient("https://account.blob.core.windows.net");
        Azure::Storage::Blobs::BlobContainerClient containerClient(
            "https://account.blob.core.windows.net/container");
        Azure::Storage::Blobs::BlobClient blobClinet(
            "https://account.blob.core.windows.net/container/blob");
        Azure::Storage::Blobs::BlockBlobClient blockBlobClinet(
            "https://account.blob.core.windows.net/container/blob");
        Azure::Storage::Blobs::PageBlobClient pageBlobClinet(
            "https://account.blob.core.windows.net/container/blob");
        Azure::Storage::Blobs::AppendBlobClient appendBlobClinet(
            "https://account.blob.core.windows.net/container/blob");
        Azure::Storage::Blobs::BlobLeaseClient leaseClient(
            containerClient, Azure::Storage::Blobs::BlobLeaseClient::CreateUniqueLeaseId());

        Azure::Storage::Sas::BlobSasBuilder sasBuilder;

        Azure::Storage::StorageSharedKeyCredential keyCredential("account", "key");
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++14", "test.cpp", "-o", "test",
                    "-L#{lib}", "-lazure-storage-blobs",
                    "-L#{formula_opt_lib("azure-core-cpp")}", "-lazure-core"
    system "./test"
  end
end
