package com.example.projectmobileandroid.Network

import android.util.Log
import okhttp3.Dns
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.UnknownHostException

object PublicIpv4Dns : Dns {
    private const val TAG = "NYT_NETWORK"
    private val dnsServers = listOf("1.1.1.1", "8.8.8.8")

    override fun lookup(hostname: String): List<InetAddress> {
        dnsServers.forEach { server ->
            runCatching {
                queryIpv4(hostname, server)
            }.onSuccess { addresses ->
                if (addresses.isNotEmpty()) {
                    Log.d(
                        TAG,
                        "DNS $hostname via $server -> ${addresses.joinToString { it.hostAddress.orEmpty() }}"
                    )
                    return addresses
                }
            }.onFailure { throwable ->
                Log.e(TAG, "DNS $hostname via $server failed", throwable)
            }
        }

        throw UnknownHostException("Unable to resolve $hostname using public IPv4 DNS")
    }

    private fun queryIpv4(hostname: String, server: String): List<InetAddress> {
        DatagramSocket().use { socket ->
            socket.soTimeout = 2_000

            val query = buildDnsQuery(hostname)
            val request = DatagramPacket(
                query,
                query.size,
                InetSocketAddress(server, 53)
            )
            socket.send(request)

            val buffer = ByteArray(512)
            val response = DatagramPacket(buffer, buffer.size)
            socket.receive(response)

            return parseIpv4Answers(buffer.copyOf(response.length))
        }
    }

    private fun buildDnsQuery(hostname: String): ByteArray {
        val output = ByteArrayOutputStream()
        val data = DataOutputStream(output)
        val queryId = 0x4E59

        data.writeShort(queryId)
        data.writeShort(0x0100)
        data.writeShort(1)
        data.writeShort(0)
        data.writeShort(0)
        data.writeShort(0)

        hostname.split('.').forEach { label ->
            data.writeByte(label.length)
            data.write(label.encodeToByteArray())
        }
        data.writeByte(0)
        data.writeShort(1)
        data.writeShort(1)

        return output.toByteArray()
    }

    private fun parseIpv4Answers(data: ByteArray): List<InetAddress> {
        if (data.size < 12) return emptyList()

        val questionCount = readUnsignedShort(data, 4)
        val answerCount = readUnsignedShort(data, 6)
        var offset = 12

        repeat(questionCount) {
            offset = skipDnsName(data, offset) + 4
            if (offset > data.size) return emptyList()
        }

        val addresses = mutableListOf<InetAddress>()
        repeat(answerCount) {
            offset = skipDnsName(data, offset)
            if (offset + 10 > data.size) return@repeat

            val type = readUnsignedShort(data, offset)
            val recordClass = readUnsignedShort(data, offset + 2)
            val length = readUnsignedShort(data, offset + 8)
            offset += 10

            if (offset + length > data.size) return@repeat

            if (type == 1 && recordClass == 1 && length == 4) {
                addresses += InetAddress.getByAddress(data.copyOfRange(offset, offset + 4))
            }
            offset += length
        }

        return addresses
    }

    private fun skipDnsName(data: ByteArray, startOffset: Int): Int {
        var offset = startOffset

        while (offset < data.size) {
            val length = data[offset].toInt() and 0xFF
            if (length == 0) return offset + 1
            if ((length and 0xC0) == 0xC0) return offset + 2
            offset += length + 1
        }

        return data.size
    }

    private fun readUnsignedShort(data: ByteArray, offset: Int): Int {
        return ((data[offset].toInt() and 0xFF) shl 8) or
            (data[offset + 1].toInt() and 0xFF)
    }
}
