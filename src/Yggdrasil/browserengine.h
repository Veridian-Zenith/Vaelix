#ifndef BROWSERENGINE_H
#define BROWSERENGINE_H

#include <QObject>
#include <QString>
#include <QWebEngineView>
#include <QWebEngineProfile>
#include <QWebEnginePage>
#include <QUrl>
#include <QTimer>
#include <QNetworkReply>
#include <QJsonObject>
#include <QSettings>

class BrowserEngine : public QObject
{
    Q_OBJECT

public:
    explicit BrowserEngine(QObject *parent = nullptr);
    ~BrowserEngine();

    // Core functionality
    void initialize();
    void navigateToUrl(const QUrl &url, bool privateMode = false);
    void reload();
    void stop();
    void goBack();
    void goForward();

    // Enhanced Security & Privacy methods
    void enablePrivacyMode();
    void disablePrivacyMode();
    bool isPrivacyModeEnabled() const { return m_privacyMode; }

    void enableAdBlocker(bool enable);
    void enableTrackerProtection(bool enable);
    void enableFingerprintingProtection(bool enable);

    // Enhanced Performance methods
    void enablePredictiveLoading(bool enable);
    void setMemoryLimit(int limitMB);
    void suspendBackgroundTabs(bool enable);

    // Enhanced Features
    void enableSmartFeatures(bool enable);

    // Analytics & Monitoring
    QJsonObject getPrivacyMetrics() const;
    QJsonObject getPerformanceMetrics() const;

signals:
    void titleChanged(const QString &title);
    void urlChanged(const QString &url);
    void loadStarted();
    void loadFinished(bool success);
    void securityLevelChanged(const QString &level);
    void privacyScoreChanged(int score);
    void trackingBlocked(int count);
    void performanceAlert(const QString &message);

public slots:
    void handleUrlChange(const QUrl &url);
    void handleLoadProgress(int progress);
    void updatePrivacyScore();
    void optimizeMemoryUsage();

private:
    void setupBasicSecurity();
    void setupPerformanceMonitoring();
    void setupSmartFeatures();

    // Web engine components
    QWebEngineView *m_webView;
    QWebEngineProfile *m_profile;
    QWebEnginePage *m_page;

    // State management
    bool m_initialized;
    bool m_privacyMode;
    bool m_adBlockEnabled;
    bool m_trackerProtectionEnabled;
    bool m_fingerprintingProtectionEnabled;
    bool m_predictiveLoadingEnabled;
    bool m_backgroundTabSuspensionEnabled;
    bool m_smartFeaturesEnabled;

    // Performance metrics
    int m_memoryLimitMB;
    int m_currentPrivacyScore;
    int m_trackersBlocked;
    qint64 m_startTime;
    QTimer *m_performanceTimer;
    QTimer *m_privacyTimer;

    // Configuration
    QSettings *m_settings;

private slots:
    void onLoadFinished(bool ok);
    void onLoadStarted();
    void onUrlChanged(const QUrl &url);
    void onTitleChanged(const QString &title);
    void updateSecurityScore();
    void handlePerformanceMetrics();
    void processBasicAdBlock();
};

#endif // BROWSERENGINE_H
