package net.e1547

import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var coverArmed = false
    private var coverText: String? = null
    private var coverBackground = Color.WHITE
    private var coverBadge = Color.BLACK
    private var coverBadgeForeground = Color.WHITE
    private var coverForeground = Color.BLACK
    private var cover: FrameLayout? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "e1547/secure_display")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "arm" -> {
                        // The codec encodes colors beyond the int32 range
                        // as longs, so the color arguments are read as
                        // numbers and narrowed afterwards; a direct int
                        // cast would crash every launch.
                        fun color(name: String, fallback: Int): Int =
                            (call.argument<Number>(name) ?: fallback).toInt()
                        // The theme may have changed between arms, so drop
                        // the built cover and let the next leave rebuild
                        // it; the old one leaves the decor view with it.
                        cover?.let { (it.parent as? ViewGroup)?.removeView(it) }
                        cover = null
                        coverArmed = call.argument<Boolean>("enabled") ?: false
                        coverText = call.argument("text")
                        coverBackground = color("background", coverBackground)
                        coverBadge = color("badge", coverBadge)
                        coverBadgeForeground = color("onBadge", coverBadgeForeground)
                        coverForeground = color("foreground", coverForeground)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // The app switcher screenshot of a protected app shows this cover:
    // a themed shield card instead of whatever the system or a race
    // decides to put there. The cover flips synchronously on the
    // user-leave hook, which fires before the snapshot is taken, and
    // clears again once the app is front and center.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        showCover()
    }

    override fun onPause() {
        showCover()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        hideCover()
    }

    private fun showCover() {
        if (!coverArmed || isFinishing || isInMultiWindowMode) {
            return
        }
        val view = cover ?: buildCover().also { built ->
            cover = built
            (window.decorView as? ViewGroup)?.addView(
                built,
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
        }
        view.visibility = View.VISIBLE
        view.bringToFront()
    }

    private fun hideCover() {
        cover?.visibility = View.GONE
    }

    private fun buildCover(): FrameLayout {
        fun dp(value: Int): Int =
            TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                value.toFloat(),
                resources.displayMetrics,
            ).toInt()

        val badge = FrameLayout(this)
        badge.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(coverBadge)
        }
        badge.layoutParams =
            LinearLayout.LayoutParams(dp(96), dp(96)).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }

        val icon = ImageView(this)
        icon.setImageResource(R.drawable.ic_secure_cover)
        icon.setColorFilter(coverBadgeForeground)
        icon.layoutParams =
            FrameLayout.LayoutParams(dp(48), dp(48), Gravity.CENTER)
        badge.addView(icon)

        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
        }
        column.addView(badge)
        coverText?.let { text ->
            column.addView(
                TextView(this).apply {
                    this.text = text
                    setTextColor(coverForeground)
                    textSize = 16f
                    typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
                    gravity = Gravity.CENTER
                    setPadding(dp(32), dp(20), dp(32), 0)
                },
            )
        }

        return FrameLayout(this).apply {
            setBackgroundColor(coverBackground)
            addView(
                column,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    Gravity.CENTER,
                ),
            )
        }
    }

    // This is a hack to prevent media_kit from hard-crashing the app
    override fun finishAfterTransition() {
        moveTaskToBack(true)
    }
}
