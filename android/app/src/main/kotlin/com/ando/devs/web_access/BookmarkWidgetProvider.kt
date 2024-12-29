package com.ando.devs.web_access

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.net.Uri
import android.app.PendingIntent
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BookmarkWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.bookmark_widget_layout).apply {
                // Actualiza tus vistas aquí
                setTextViewText(R.id.widget_text, widgetData.getString("name", "Bookmark"))
                
                // Configura el intent para abrir la app o una URL
                val pendingIntent = if (widgetData.getString("type", "") == "bookmark") {
                    val url = widgetData.getString("url", "")
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(url))
                } else {
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                }
                setOnClickPendingIntent(R.id.widget_text, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}